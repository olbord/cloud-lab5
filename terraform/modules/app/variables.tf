variable "name" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "security_group_id" {
  type = string
}

variable "user_data_script" {
  description = "Path to the boot-up shell script"
  type        = string
}

variable "app_source_dir" {
  description = "Directory containing compose.yaml, .env, api/, db/, proxy/"
  type        = string
}
