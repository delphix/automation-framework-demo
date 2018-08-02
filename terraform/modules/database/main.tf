resource "aws_subnet" "database1" {
    vpc_id = "${var.vpc_id}"
    cidr_block = "${var.database_networks[0]}"
    availability_zone = "${var.database_azs[0]}"
    map_public_ip_on_launch = false

    tags {
        Name = "${var.project}_sub_database1"
        "dlpx:Project" = "${var.project}"
        "dlpx:Owner" = "${var.owner}"
        "dlpx:Expiration" = "${var.expiration}"
        "dlpx:CostCenter" = "${var.cost_center}"
    }
}

output "db1_subnet_id" {
    value = "${aws_subnet.database1.id}"
}

resource "aws_subnet" "database2" {
    vpc_id = "${var.vpc_id}"
    cidr_block = "${var.database_networks[1]}"
    availability_zone = "${var.database_azs[1]}"
    map_public_ip_on_launch = false

    tags {
        Name = "${var.project}_sub_database2"
        "dlpx:Project" = "${var.project}"
        "dlpx:Owner" = "${var.owner}"
        "dlpx:Expiration" = "${var.expiration}"
        "dlpx:CostCenter" = "${var.cost_center}"
    }
}

output "db2_subnet_id" {
    value = "${aws_subnet.database2.id}"
}

resource "aws_db_subnet_group" "default" {
  name = "${var.project}_database_subnet_group"
  subnet_ids = ["${aws_subnet.database1.id}", "${aws_subnet.database2.id}"]

  tags {
    "dlpx:Project" = "${var.project}"
    "dlpx:Owner" = "${var.owner}"
    "dlpx:Expiration" = "${var.expiration}"
    "dlpx:CostCenter" = "${var.cost_center}"
  }
}

output "sg_group_id" {
    value = "${aws_db_subnet_group.default.id}"
}

data "aws_kms_secrets" "db" {
  secret {
    name    = "master_password"
    payload = "${var.kms_password}"

    context {
      foo = "bar"
    }
  }
}

resource "aws_db_instance" "daf-postgres" {
  allocated_storage        = 20 # gigabytes
  backup_retention_period  = 7   # in days
  db_subnet_group_name     = "${var.project}_database_subnet_group"
  engine                   = "postgres"
  engine_version           = "9.6.9"
  identifier               = "${var.project}-postgres"
  instance_class           = "db.t2.micro"
  multi_az                 = false
  name                     = "${var.project}postgres"
  parameter_group_name     = "daf-postgres96"
  password                 = "${data.aws_kms_secrets.db.plaintext["master_password"]}"
  port                     = 5432
  publicly_accessible      = true
  storage_encrypted        = false
  storage_type             = "gp2"
  username                 = "dafpostgresuser"
  vpc_security_group_ids   = ["${aws_security_group.daf-postgres.id}"]
  skip_final_snapshot = true
}

output "dbname" {
    value = "${aws_db_instance.daf-postgres.name}"
}

output "host" {
    value = "${aws_db_instance.daf-postgres.endpoint}"
}

output "port" {
    value = "${aws_db_instance.daf-postgres.port}"
}

output "username" {
    value = "${aws_db_instance.daf-postgres.username}"
}

resource "aws_security_group" "daf-postgres" {
  name = "${var.project}-postgres"
  description = "RDS postgres servers (terraform-managed)"
  vpc_id = "${var.vpc_id}"

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
