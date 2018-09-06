variable "server_network" {
  description = "The network for the delphix engine and target host"
  default = "10.0.1.0/24"
}

variable "vpc_id" {
  description = "VPC ID for the network."
}

variable "key_name" {
  description = "Name of the SSH keypair to use in AWS (do not include .pem extension)."
}

variable "jenkins_sg" {
  description = "Jenkins Security Group ID."
}

variable "owner" {}
variable "expiration" {}
variable "cost_center" {}
variable "project" {}
variable "environment" {}
variable "static_ips" {
  type  = "list"
}
