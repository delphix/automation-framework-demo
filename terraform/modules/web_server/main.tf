data "aws_ami" "delphix-ready-ami" {
  most_recent = true
  owners = ["self"]
  filter {
    name = "name"
    values = ["${var.ami_name}"]
  }
}

resource "aws_security_group" "security_group" {
  name = "${var.project}_${var.env_tag}_app_sg"
  description = "Allow Limited Access to Web Server"
  vpc_id = "${var.vpc_id}"

  ingress {
      from_port = 22
      to_port = 22
      protocol = "tcp"
      cidr_blocks = "${var.static_ips}"
  }

  ingress {
      from_port = 80
      to_port = 80
      protocol = "tcp"
      cidr_blocks = "${var.static_ips}"
  }

  ingress {
      from_port = 8080
      to_port = 8080
      protocol = "tcp"
      cidr_blocks = "${var.static_ips}"
  }

  ingress {
      from_port = 22
      to_port = 22
      protocol = "tcp"
      security_groups = ["${var.jenkins_sg}"]
  }

  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    self = true
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "${var.project}_${var.env_tag}_app_sg"
    "dlpx:Project" = "${var.project}"
    "dlpx:Owner" = "${var.owner}"
    "dlpx:Expiration" = "${var.expiration}"
    "dlpx:CostCenter" = "${var.cost_center}"
  }
}

output "security_group_id" {
    value = "${aws_security_group.security_group.id}"
}


resource "aws_instance" "web_server" {
  ami = "${data.aws_ami.delphix-ready-ami.id}"
  instance_type = "t2.micro"
  key_name = "${var.key_name}"

  vpc_security_group_ids = ["${aws_security_group.security_group.id}"]
  subnet_id = "${var.subnet_id}"

  #Instance tags
  tags {
    Name = "${var.project}_${var.env_tag}_app"
    "dlpx:Project" = "${var.project}"
    "dlpx:Owner" = "${var.owner}"
    "dlpx:Expiration" = "${var.expiration}"
    "dlpx:CostCenter" = "${var.cost_center}"
  }
}

output "public_ip" {
  value = "${aws_instance.web_server.public_ip}"
}

output "instance_id" {
  value = "${aws_instance.web_server.id}"
}

output "private_ip" {
  value = "${aws_instance.web_server.private_ip}"
}

data "aws_kms_secrets" "db" {
  secret {
    name    = "name"
    payload = "${var.db_name}"
  }
  secret {
    name    = "user"
    payload = "${var.db_user}"
  }
  secret {
    name    = "pass"
    payload = "${var.db_pass}"
  }
  secret {
    name    = "jwt"
    payload = "${var.jwt_secret}"
  }
}

resource "null_resource" "deploy_stack" {
  provisioner "local-exec" {
    command = "sed -i -e 's#spring.datasource.url=.*#spring.datasource.url=jdbc:postgresql://${var.db_url}:${var.db_port}/${data.aws_kms_secrets.db.plaintext["name"]}#g' ../src/main/resources/application.properties"
  }
  provisioner "local-exec" {
    command = "sed -i -e 's/spring.datasource.username=.*/spring.datasource.username=${data.aws_kms_secrets.db.plaintext["user"]}/g' ../src/main/resources/application.properties"
  }
  provisioner "local-exec" {
    command = "sed -i -e 's/spring.datasource.password=.*/spring.datasource.password=${data.aws_kms_secrets.db.plaintext["pass"]}/g' ../src/main/resources/application.properties"
  }
  provisioner "local-exec" {
    command = "sed -i -e 's/jwt.secret=.*/jwt.secret=${data.aws_kms_secrets.db.plaintext["jwt"]}/g' ../src/main/resources/application.properties"
  }
  provisioner "local-exec" {
    command = "sed -i -e 's#APIBase:.*#APIBase: \"//${aws_instance.web_server.public_ip}:8080\"#g' ../client/src/environments/environment.prod.ts"
  }
  provisioner "local-exec" {
    command = "ansible-playbook -e public_ip='${aws_instance.web_server.private_ip}' deploy.yaml -vvv"
  }
}
