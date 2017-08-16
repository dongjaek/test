variable "role" {}
variable "role_override" {
  default = ""
}
variable "subrole" {}
variable "environment" {
  default = "production"
}
variable "instance_type" {
  default = "n1-standard-1"
}
variable "disks" {
  type = "map"
  default = {}
}

variable "region" {}
variable "zones" { type = "list" }
variable "image" {}
variable "subnet" {}
variable "network" {}
variable "project" {}

variable "frontend_lb" {
  default = ""
}
variable "lb_port" {
  default = ""
}
variable "dns_alias" {
  default = "puppetdb"
}
variable "region_dns_suffix" {
  default = ""
}
variable "region_dns_zone_name" {
  default = ""
}
variable "dc" {}
variable "tld" {}
