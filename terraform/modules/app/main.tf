# Latest Ubuntu 24.04 LTS (x86_64) AMI published by Canonical
data "aws_ssm_parameter" "ubuntu" {
  name = "/aws/service/canonical/ubuntu/server/24.04/stable/current/amd64/hvm/ebs-gp3/ami-id"
}

# SSH key (generated; private key saved locally)
resource "tls_private_key" "ssh" {
  algorithm = "ED25519"
}

resource "aws_key_pair" "this" {
  key_name   = "${var.name}-key"
  public_key = tls_private_key.ssh.public_key_openssh
}

resource "local_sensitive_file" "private_key" {
  content         = tls_private_key.ssh.private_key_openssh
  filename        = "${path.root}/${var.name}-key.pem"
  file_permission = "0600"
}

resource "aws_instance" "this" {
  ami                    = data.aws_ssm_parameter.ubuntu.value
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [var.security_group_id]
  key_name               = aws_key_pair.this.key_name
  user_data              = file(var.user_data_script)

  user_data_replace_on_change = true

  metadata_options {
    http_tokens = "required" # IMDSv2
  }

  root_block_device {
    volume_size = 20 # GB; room for images, build cache and the Postgres volume
    volume_type = "gp3"
  }

  tags = { Name = "${var.name}-vm" }
}

resource "aws_eip" "this" {
  domain   = "vpc"
  instance = aws_instance.this.id
  tags     = { Name = "${var.name}-eip" }
}

# Zip the project (compose.yaml, .env, api/, db/, proxy/) without the terraform dir
data "archive_file" "app" {
  type        = "zip"
  source_dir  = var.app_source_dir
  output_path = "${path.root}/.app.zip"
  excludes    = ["terraform", ".git", ".terraform"]
}

# Upload the project and run `docker compose up`
resource "null_resource" "deploy" {
  triggers = {
    instance = aws_instance.this.id
    app_hash = data.archive_file.app.output_md5
  }

  connection {
    type        = "ssh"
    host        = aws_eip.this.public_ip
    user        = "ubuntu"
    private_key = tls_private_key.ssh.private_key_openssh
    timeout     = "5m"
  }

  provisioner "file" {
    source      = data.archive_file.app.output_path
    destination = "/tmp/app.zip"
  }

  provisioner "remote-exec" {
    inline = [
      "cloud-init status --wait",   # wait until install_docker.sh has finished
      "sudo rm -rf /opt/app && sudo mkdir -p /opt/app",
      "sudo unzip -q -o /tmp/app.zip -d /opt/app",
      "cd /opt/app && sudo docker compose up -d --build",
    ]
  }
}
