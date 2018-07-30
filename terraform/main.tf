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
  vpc_id="${module.vpc.vpc_id}"
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
