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
  static_ips = "${var.static_ips}"
  vpc_id = "${module.vpc.vpc_id}"
  key_name = "Derek-CTO-west-2"
  jenkins_sg = "sg-0e9fe830541933f0b"
}

module "delphix_target" {
  source = "./modules/delphix_target"
  environment = "${terraform.workspace}"
  owner = "${var.owner}"
  expiration = "${var.expiration}"
  cost_center = "${var.cost_center}"
  project = "${var.project}"
  static_ips = "${var.static_ips}"
  vpc_id = "${module.vpc.vpc_id}"
  key_name = "Derek-CTO-west-2"
  ami_name = "delphix-postgres-*"
  de_security_group = "${module.delphix_engine.security_group_id}"
  subnet_id = "${module.delphix_engine.subnet_id}"
  jenkins_sg = "sg-0e9fe830541933f0b"
  dev_web_sg = "${module.dev_web_server.security_group_id}"
}

module "dms" {
  source = "./modules/dms"
  environment = "${terraform.workspace}"
  owner = "${var.owner}"
  expiration = "${var.expiration}"
  cost_center = "${var.cost_center}"
  project = "${var.project}"
  kms_password = "AQICAHjVk6pILmgy+NWJt098mQz7G37xRyA8NKRGz1oJgqayogESEOwlFpioOXGXNSTuc+ddAAAAbDBqBgkqhkiG9w0BBwagXTBbAgEAMFYGCSqGSIb3DQEHATAeBglghkgBZQMEAS4wEQQMpufQVZV4IW4a12lFAgEQgCl7IKQUt3Lg0Al06tri5hq0IhCPg9DDF4fs6Ud+gn9vnNrJY8e27rLDQw=="
  source_dbname = "postgres"
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

module "ansible_pem" {
  source = "./modules/keyfile"
  pem = <<EOF
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
EOF
}

module "dev_web_server" {
  source = "./modules/web_server"
  environment = "${terraform.workspace}"
  owner = "${var.owner}"
  expiration = "${var.expiration}"
  cost_center = "${var.cost_center}"
  project = "${var.project}"
  static_ips = "${var.static_ips}"
  vpc_id = "${module.vpc.vpc_id}"
  key_name = "Derek-CTO-west-2"
  ami_name = "daf-app-*"
  subnet_id = "${module.delphix_engine.subnet_id}"
  jenkins_sg = "sg-0e9fe830541933f0b"
  env_tag ="develop"
  db_url = "${module.delphix_target.private_ip}"
  db_port = "5434"
  db_name = "AQICAHh+IJ9ZGZ6ND/EG3/5iYCK2lApzMxUuVM3qFtq0OzBORwEaneHrCmM9nIZsOph3RquxAAAAZjBkBgkqhkiG9w0BBwagVzBVAgEAMFAGCSqGSIb3DQEHATAeBglghkgBZQMEAS4wEQQMDWmBqRH4JoyAeP9kAgEQgCPSpRgjAmTbQAc5N+vBi1lLhmKrEHTUJgBbJDg/JkUtxGUuWQ=="
  db_user = "AQICAHh+IJ9ZGZ6ND/EG3/5iYCK2lApzMxUuVM3qFtq0OzBORwFmgJ0Sp1P2rIVXNlgoR7r+AAAAZjBkBgkqhkiG9w0BBwagVzBVAgEAMFAGCSqGSIb3DQEHATAeBglghkgBZQMEAS4wEQQMzq0oilNFDR53AqYWAgEQgCPBHw2pXxdHz4GW7bXZ71eip40KHhPqgQTb7HRkUAMaiR+Osw=="
  db_pass = "AQICAHh+IJ9ZGZ6ND/EG3/5iYCK2lApzMxUuVM3qFtq0OzBORwFe5KlJySzPZ161bnEs4bebAAAAbDBqBgkqhkiG9w0BBwagXTBbAgEAMFYGCSqGSIb3DQEHATAeBglghkgBZQMEAS4wEQQMkG40F3kDjO9nCTiWAgEQgCl0L3ciYG0aAie6LD2LnwZld8SrCxNtK9FW8L0sf351leSPmnqR26Bm1Q=="
  jwt_secret = "AQICAHh+IJ9ZGZ6ND/EG3/5iYCK2lApzMxUuVM3qFtq0OzBORwHYij2+HRangHqrNyWTysmZAAAAijCBhwYJKoZIhvcNAQcGoHoweAIBADBzBgkqhkiG9w0BBwEwHgYJYIZIAWUDBAEuMBEEDPwElthCkIRyJVOiOAIBEIBGbgAuDbuvYWfsSzOT2d+ur/iigJPUdPwExqrn3rbmEUGN8CsJ9SgD620Jei70x6JvDMtTus68koTR9T7YOb7bPhoEaaJhZg=="
}

module "prod_web_server" {
  source = "./modules/web_server"
  environment = "${terraform.workspace}"
  owner = "${var.owner}"
  expiration = "${var.expiration}"
  cost_center = "${var.cost_center}"
  project = "${var.project}"
  static_ips = "${var.static_ips}"
  vpc_id = "${module.vpc.vpc_id}"
  key_name = "Derek-CTO-west-2"
  ami_name = "daf-app-*"
  subnet_id = "${module.delphix_engine.subnet_id}"
  jenkins_sg = "sg-0e9fe830541933f0b"
  env_tag ="prod"
  db_url = "daf-postgres.chnrjno1jp2y.us-west-2.rds.amazonaws.com"
  db_port = "5432"
  db_name = "AQICAHh+IJ9ZGZ6ND/EG3/5iYCK2lApzMxUuVM3qFtq0OzBORwGpjfR9K/80922z5FJPHe9KAAAAZjBkBgkqhkiG9w0BBwagVzBVAgEAMFAGCSqGSIb3DQEHATAeBglghkgBZQMEAS4wEQQMOMJksXrspm8zYqMaAgEQgCM53SqJXDzHc1C+RSCjHHd2ogwawsmHv0Z/VhzBg85z94HBKQ=="
  db_user = "AQICAHh+IJ9ZGZ6ND/EG3/5iYCK2lApzMxUuVM3qFtq0OzBORwEoOTpTObyDOsIVfO94wWmhAAAAbTBrBgkqhkiG9w0BBwagXjBcAgEAMFcGCSqGSIb3DQEHATAeBglghkgBZQMEAS4wEQQMX0E8bSxcHkUBEAdtAgEQgCqiDpN282lwUI2T8wcOZaDGN2Yy7FZducQPv8YVMQ8N3IMdwQ57S/L9SyI="
  db_pass = "AQICAHh+IJ9ZGZ6ND/EG3/5iYCK2lApzMxUuVM3qFtq0OzBORwHUpHWNXKGvrTADQlidN6IyAAAAbDBqBgkqhkiG9w0BBwagXTBbAgEAMFYGCSqGSIb3DQEHATAeBglghkgBZQMEAS4wEQQMb3aFhevTOIImda0QAgEQgCnlsqs+hzNLNRoi5kZPSy0+Ae1hw2nP3SwT4kTUWfI8Tvk/WQvlyyJSeQ=="
  jwt_secret = "AQICAHh+IJ9ZGZ6ND/EG3/5iYCK2lApzMxUuVM3qFtq0OzBORwGHujIiOEDAKJEEJlnjKpKOAAAAijCBhwYJKoZIhvcNAQcGoHoweAIBADBzBgkqhkiG9w0BBwEwHgYJYIZIAWUDBAEuMBEEDMmVREQ8wUyi7D2hTAIBEIBGuOEAANgB3Z6HdoDbrG8Xl/xlOrtv0OJ4geacRSHO+TMHSH7nFQWfUFo/E0xwDsCss8DoFWxqpRoR9fEF0MpGePpm9it/xA=="
}

output "prod_ec2_ip" {
    value = "${module.prod_web_server.public_ip}"
}

output "dev_ec2_ip" {
    value = "${module.dev_web_server.public_ip}"
}
