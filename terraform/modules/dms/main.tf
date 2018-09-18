data "aws_kms_secrets" "db" {
  secret {
    name    = "master_password"
    payload = "${var.kms_password}"

    context {
      foo = "bar"
    }
  }
}

resource "aws_dms_endpoint" "source" {
  database_name               = "${var.source_dbname}"
  endpoint_id                 = "${var.project}-dms-source"
  endpoint_type               = "source"
  engine_name                 = "postgres"
  password                    = "${data.aws_kms_secrets.db.plaintext["master_password"]}"
  port                        = "${var.source_port}"
  ssl_mode                    = "none"
  server_name                 = "${var.source_host}"
  username                    = "${var.source_username}"

  tags {
    Name = "${var.project}_aws_dms_endpoint_source"
    "dlpx:Project" = "${var.project}"
    "dlpx:Owner" = "${var.owner}"
    "dlpx:Expiration" = "${var.expiration}"
    "dlpx:CostCenter" = "${var.cost_center}"
  }
}

resource "aws_dms_endpoint" "target" {
  database_name               = "${var.target_dbname}"
  endpoint_id                 = "${var.project}-dms-target"
  endpoint_type               = "target"
  engine_name                 = "postgres"
  password                    = "${data.aws_kms_secrets.db.plaintext["master_password"]}"
  port                        = "${var.target_port}"
  ssl_mode                    = "none"
  server_name                 = "${var.target_host}"
  username                    = "${var.target_username}"

  tags {
    Name = "${var.project}_aws_dms_endpoint_target"
    "dlpx:Project" = "${var.project}"
    "dlpx:Owner" = "${var.owner}"
    "dlpx:Expiration" = "${var.expiration}"
    "dlpx:CostCenter" = "${var.cost_center}"
  }
}

resource "aws_dms_replication_subnet_group" "dms" {
  replication_subnet_group_description = "DMS Replication Subnet Group"
  replication_subnet_group_id          = "daf-repl-sub-group"
  subnet_ids                           = ["${var.db1_subnet_id}", "${var.db2_subnet_id}"]
}


resource "aws_dms_replication_instance" "dms" {
  allocated_storage            = 20
  apply_immediately            = true
  auto_minor_version_upgrade   = false
  multi_az                     = false
  publicly_accessible          = false
  replication_instance_class   = "dms.t2.large"
  replication_instance_id      = "dms-replication-instance-${var.environment}"
  replication_subnet_group_id  = "${aws_dms_replication_subnet_group.dms.id}"
  vpc_security_group_ids       = ["${var.sg_id}"]

  tags {
    Name = "${var.project}_aws_dms_replication_instance"
    "dlpx:Project" = "${var.project}"
    "dlpx:Owner" = "${var.owner}"
    "dlpx:Expiration" = "${var.expiration}"
    "dlpx:CostCenter" = "${var.cost_center}"
  }
}

resource "aws_dms_replication_task" "dms" {
  migration_type            = "full-load-and-cdc"
  replication_instance_arn  = "${aws_dms_replication_instance.dms.replication_instance_arn}"
  replication_task_id       = "dms-replication-task-${var.environment}"
  source_endpoint_arn       = "${aws_dms_endpoint.source.endpoint_arn}"
  table_mappings            = "{\"rules\":[{\"rule-type\":\"selection\",\"rule-id\":\"1\",\"rule-name\":\"1\",\"object-locator\":{\"schema-name\":\"public\",\"table-name\":\"%\"},\"rule-action\":\"include\"},{\"rule-type\":\"selection\",\"rule-id\":\"2\",\"rule-name\":\"2\",\"object-locator\":{\"schema-name\":\"public\",\"table-name\":\"databasechange%\"},\"rule-action\":\"exclude\"},{\"rule-type\":\"selection\",\"rule-id\":\"3\",\"rule-name\":\"3\",\"object-locator\":{\"schema-name\":\"public\",\"table-name\":\"users\"},\"rule-action\":\"exclude\"}]}"
  replication_task_settings = "${trimspace(replace(replace(file("${path.module}/settings/replication_settings.json"), "/\\n\\s+/", ""),"/\\s+/", ""))}"
  target_endpoint_arn       = "${aws_dms_endpoint.target.endpoint_arn}"

  tags {
    Name = "${var.project}_repl_task"
    "dlpx:Project" = "${var.project}"
    "dlpx:Owner" = "${var.owner}"
    "dlpx:Expiration" = "${var.expiration}"
    "dlpx:CostCenter" = "${var.cost_center}"
  }

  #The below block is a workaround for issue: https://github.com/terraform-providers/terraform-provider-aws/issues/1513
  lifecycle {
	  ignore_changes = ["replication_task_settings"]
  }
}
