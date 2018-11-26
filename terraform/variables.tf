variable "aws_region" {
  default = "us-west-2"
}

variable "owner" {
  description = "Tag to designate primary contact"
  default = "Derek Smart"
}

variable "expiration" {
  description = "Tag to designate when asset should be terminated"
  default = "2020-08-27"
}

variable "cost_center" {
  description = "Tag to designate where costs should be assigned"
  default = "305000 - Development Engineering"
}

variable "project" {
  description = "Tag to designate affiliated project"
  default = "daf"
}

variable "static_ips" {
  description = "Array of white-listed static IPs."
  default = ["69.180.21.111/32","76.217.115.65/32","4.16.207.62/32"]
}
