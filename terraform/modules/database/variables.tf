variable "database_networks" {
  description = "RDS and DMS require two dedicated networks."
  default = ["10.0.2.0/24","10.0.3.0/24"]
}

variable "database_azs" {
  description = "RDS requires two different availability zones in the region."
  default = ["us-west-2a","us-west-2b"]
}

variable "vpc_id" {
  description = "VPC ID for the network."
}

variable "kms_password" {
  description = "KMS Encrypted Master Password for Database."
}

variable "owner" {}
variable "expiration" {}
variable "cost_center" {}
variable "project" {}
variable "environment" {}
