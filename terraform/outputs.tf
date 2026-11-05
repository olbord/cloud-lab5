output "public_ip" {
  value = module.app.public_ip
}

output "app_url" {
  value = "http://${module.app.public_ip}"
}

output "ssh_command" {
  value = "ssh -i ${module.app.private_key_path} ubuntu@${module.app.public_ip}"
}
