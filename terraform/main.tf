terraform {
  backend "s3" {
    bucket = "daf-terraform-remote-state"
    key    = "daf"
    region = "us-west-2"
  }
}

provider "aws" {
  region = "${var.aws_region}"
}

module "vpc" {
  source = "./modules/vpc"
  environment = "${terraform.workspace}"
  owner = "${var.owner}"
  expiration = "${var.expiration}"
  cost_center = "${var.cost_center}"
  project = "${var.project}"
}

module "database" {
  source = "./modules/database"
  environment = "${terraform.workspace}"
  owner = "${var.owner}"
  expiration = "${var.expiration}"
  cost_center = "${var.cost_center}"
  project = "${var.project}"
  vpc_id = "${module.vpc.vpc_id}"
  kms_password = "AQICAHjVk6pILmgy+NWJt098mQz7G37xRyA8NKRGz1oJgqayogESEOwlFpioOXGXNSTuc+ddAAAAbDBqBgkqhkiG9w0BBwagXTBbAgEAMFYGCSqGSIb3DQEHATAeBglghkgBZQMEAS4wEQQMpufQVZV4IW4a12lFAgEQgCl7IKQUt3Lg0Al06tri5hq0IhCPg9DDF4fs6Ud+gn9vnNrJY8e27rLDQw=="
}

module "delphix_engine" {
  source = "./modules/delphix_engine"
  environment = "${terraform.workspace}"
  owner = "${var.owner}"
  expiration = "${var.expiration}"
  cost_center = "${var.cost_center}"
  project = "${var.project}"
  vpc_id = "${module.vpc.vpc_id}"
  key_name = "Derek-CTO-west-2"
}

module "delphix_target" {
  source = "./modules/delphix_target"
  environment = "${terraform.workspace}"
  owner = "${var.owner}"
  expiration = "${var.expiration}"
  cost_center = "${var.cost_center}"
  project = "${var.project}"
  vpc_id = "${module.vpc.vpc_id}"
  key_name = "Derek-CTO-west-2"
  ami_name = "daf-postgres-*"
  de_security_group = "${module.delphix_engine.security_group_id}"
  subnet_id = "${module.delphix_engine.subnet_id}"
}
