variable "env_ip" {
  description = "IP address for environment server."
}

variable "db_url" {
  description = "Database Host URL."
}

variable "db_name" {
  description = "KMS Encrypted value for Database Name."
}

variable "db_user" {
  description = "KMS Encrypted value for Database Username."
}

variable "db_pass" {
  description = "KMS Encrypted value for Database Password."
}

variable "jwt_secret" {
  description = "KMS Encrypted value for JWT Secret."
}
