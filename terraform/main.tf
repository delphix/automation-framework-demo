terraform {
  backend "s3" {
    bucket = "daf-terraform-remote-state"
    key    = "daf"
    region = "us-west-2"
  }
}

provider "aws" {
  region = "${var.region}"
}

data "aws_kms_secret" "db" {
  secret {
    name    = "master_password"
    payload = "AQICAHjVk6pILmgy+NWJt098mQz7G37xRyA8NKRGz1oJgqayogESEOwlFpioOXGXNSTuc+ddAAAAbDBqBgkqhkiG9w0BBwagXTBbAgEAMFYGCSqGSIb3DQEHATAeBglghkgBZQMEAS4wEQQMpufQVZV4IW4a12lFAgEQgCl7IKQUt3Lg0Al06tri5hq0IhCPg9DDF4fs6Ud+gn9vnNrJY8e27rLDQw=="

    context {
      foo = "bar"
    }
  }
}

resource "aws_db_instance" "daf-postgres" {
  allocated_storage        = 20 # gigabytes
  backup_retention_period  = 7   # in days
  db_subnet_group_name     = "${var.rds_public_subnet_group}"
  engine                   = "postgres"
  engine_version           = "10.4"
  identifier               = "daf-postgres"
  instance_class           = "db.t2.micro"
  multi_az                 = false
  name                     = "dafpostgres"
  parameter_group_name     = "default.postgres10" # if you have tuned it
  password                 = "${data.aws_kms_secret.db.master_password}"
  port                     = 5432
  publicly_accessible      = true
  storage_encrypted        = false
  storage_type             = "gp2"
  username                 = "dafpostgresuser"
  vpc_security_group_ids   = ["${aws_security_group.daf-postgres.id}"]
  skip_final_snapshot = true
}

resource "aws_security_group" "daf-postgres" {
  name = "daf-postgres"

  description = "RDS postgres servers (terraform-managed)"
  vpc_id = "${var.rds_vpc_id}"

  # Only postgres in
  ingress {
    from_port = 5432
    to_port = 5432
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic.
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
