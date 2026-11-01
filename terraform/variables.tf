variable "region" {
  type    = string
  default = "eu-north-1"
}

variable "name" {
  type    = string
  default = "lab5"
}

variable "instance_type" {
  description = "t3.micro is the smallest size that comfortably runs Postgres + image builds"
  type        = string
  default     = "t3.micro"
}

variable "admin_cidr" {
  description = "Your public IP in CIDR form (e.g. 203.0.113.7/32). Used ONLY for SSH, which is needed to upload the app."
  type        = string
}
