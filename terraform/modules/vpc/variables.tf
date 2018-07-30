variable "cidr_block" {
  description = "The network for the VPC"
  default = "10.0.0.0/16"
}

variable "server_network" {
  description = "The network for the delphix engine and target host"
  default = "10.0.1.0/24"
}

variable "owner" {}
variable "expiration" {}
variable "cost_center" {}
variable "project" {}
variable "environment" {}
