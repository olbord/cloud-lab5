output "public_ip" {
  value = aws_eip.this.public_ip
}

output "private_key_path" {
  value = local_sensitive_file.private_key.filename
}
