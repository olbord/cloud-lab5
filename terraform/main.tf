module "network" {
  source     = "./modules/network"
  name       = var.name
  admin_cidr = var.admin_cidr
}

module "app" {
  source            = "./modules/app"
  name              = var.name
  instance_type     = var.instance_type
  subnet_id         = module.network.subnet_id
  security_group_id = module.network.security_group_id

  user_data_script = "${path.root}/scripts/install_docker.sh"
  app_source_dir   = abspath("${path.root}/..")
}
