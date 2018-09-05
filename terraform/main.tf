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
  ami_name = "delphix-postgres-*"
  de_security_group = "${module.delphix_engine.security_group_id}"
  subnet_id = "${module.delphix_engine.subnet_id}"
}

module "dms" {
  source = "./modules/dms"
  environment = "${terraform.workspace}"
  owner = "${var.owner}"
  expiration = "${var.expiration}"
  cost_center = "${var.cost_center}"
  project = "${var.project}"
  kms_password = "AQICAHjVk6pILmgy+NWJt098mQz7G37xRyA8NKRGz1oJgqayogESEOwlFpioOXGXNSTuc+ddAAAAbDBqBgkqhkiG9w0BBwagXTBbAgEAMFYGCSqGSIb3DQEHATAeBglghkgBZQMEAS4wEQQMpufQVZV4IW4a12lFAgEQgCl7IKQUt3Lg0Al06tri5hq0IhCPg9DDF4fs6Ud+gn9vnNrJY8e27rLDQw=="
  source_dbname = "${module.database.dbname}"
  source_host = "${module.database.host}"
  source_port = "${module.database.port}"
  source_username = "${module.database.username}"
  target_dbname = "postgres"
  target_host = "${module.delphix_target.private_ip}"
  target_port = "5432"
  target_username = "postgres"
  sg_id = "${module.delphix_target.security_group_id}"
  db1_subnet_id = "${module.database.db1_subnet_id}"
  db2_subnet_id = "${module.database.db2_subnet_id}"
}

module "web_server" {
  source = "./modules/web_server"
  environment = "${terraform.workspace}"
  owner = "${var.owner}"
  expiration = "${var.expiration}"
  cost_center = "${var.cost_center}"
  project = "${var.project}"
  vpc_id = "${module.vpc.vpc_id}"
  key_name = "Derek-CTO-west-2"
  ami_name = "daf-app-*"
  subnet_id = "${module.delphix_engine.subnet_id}"
  db_url = "${module.delphix_target.private_ip}"
  db_name = "AQICAHh+IJ9ZGZ6ND/EG3/5iYCK2lApzMxUuVM3qFtq0OzBORwEaneHrCmM9nIZsOph3RquxAAAAZjBkBgkqhkiG9w0BBwagVzBVAgEAMFAGCSqGSIb3DQEHATAeBglghkgBZQMEAS4wEQQMDWmBqRH4JoyAeP9kAgEQgCPSpRgjAmTbQAc5N+vBi1lLhmKrEHTUJgBbJDg/JkUtxGUuWQ=="
  db_user = "AQICAHh+IJ9ZGZ6ND/EG3/5iYCK2lApzMxUuVM3qFtq0OzBORwFmgJ0Sp1P2rIVXNlgoR7r+AAAAZjBkBgkqhkiG9w0BBwagVzBVAgEAMFAGCSqGSIb3DQEHATAeBglghkgBZQMEAS4wEQQMzq0oilNFDR53AqYWAgEQgCPBHw2pXxdHz4GW7bXZ71eip40KHhPqgQTb7HRkUAMaiR+Osw=="
  db_pass = "AQICAHh+IJ9ZGZ6ND/EG3/5iYCK2lApzMxUuVM3qFtq0OzBORwFe5KlJySzPZ161bnEs4bebAAAAbDBqBgkqhkiG9w0BBwagXTBbAgEAMFYGCSqGSIb3DQEHATAeBglghkgBZQMEAS4wEQQMkG40F3kDjO9nCTiWAgEQgCl0L3ciYG0aAie6LD2LnwZld8SrCxNtK9FW8L0sf351leSPmnqR26Bm1Q=="
  jwt_secret = "AQICAHh+IJ9ZGZ6ND/EG3/5iYCK2lApzMxUuVM3qFtq0OzBORwHYij2+HRangHqrNyWTysmZAAAAijCBhwYJKoZIhvcNAQcGoHoweAIBADBzBgkqhkiG9w0BBwEwHgYJYIZIAWUDBAEuMBEEDPwElthCkIRyJVOiOAIBEIBGbgAuDbuvYWfsSzOT2d+ur/iigJPUdPwExqrn3rbmEUGN8CsJ9SgD620Jei70x6JvDMtTus68koTR9T7YOb7bPhoEaaJhZg=="
}

output "ec2_ip" {
    value = "${module.web_server.public_ip}"
}
