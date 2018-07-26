variable "region" {
  default = "us-west-2"
}

variable "rds_vpc_id" {
  default = "vpc-37cf3e4f"
  description = "Our default RDS virtual private cloud (rds_vpc)."
}

variable "rds_public_subnets" {
  default = "subnet-2dd2bc66"
  description = "The public subnets of our RDS VPC rds-vpc."
}

variable "rds_public_subnet_group" {
  default = "postgres-terraform managed"
  description = "Apparently the group name, according to the RDS launch wizard."
}
