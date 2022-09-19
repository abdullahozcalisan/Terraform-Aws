variable "vpc_cidr" {
  default = "10.10.0.0/16"
}
variable "access_ip" {}
variable "db_name" {}
variable "db_username" {
  sensitive = true
}
variable "db_password" {
  sensitive = true
}
variable "region" {
  default = "eu-west-1"
}

variable "ins_count" {
  default = 1
}