variable "subnet_id" {
  description = "The network for the delphix engine and target host"
}

variable "ami_name" {
  description = "Name of the congigured target AMI."
}

variable "de_security_group" {
  description = "ID for Delphix Engine Security Group"
}

variable "vpc_id" {
  description = "VPC ID for the network."
}

variable "key_name" {
  description = "Name of the SSH keypair to use in AWS (do not include .pem extension)."
}

variable "owner" {}
variable "expiration" {}
variable "cost_center" {}
variable "project" {}
variable "environment" {}
