variable "kms_password" {
  description = "KMS Encrypted Master Password for Database."
}

variable "source_dbname" {}
variable "source_host" {}
variable "source_port" {}
variable "source_username" {}

variable "target_dbname" {}
variable "target_host" {}
variable "target_port" {}
variable "target_username" {}

variable "sg_id" {}
variable "db1_subnet_id" {}
variable "db2_subnet_id" {}

variable "owner" {}
variable "expiration" {}
variable "cost_center" {}
variable "project" {}
variable "environment" {}
