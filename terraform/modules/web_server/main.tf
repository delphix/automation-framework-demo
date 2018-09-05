data "aws_ami" "delphix-ready-ami" {
  most_recent = true
  owners = ["self"]
  filter {
    name = "name"
    values = ["${var.ami_name}"]
  }
}

data "http" "your_ip" {
  url = "http://ipv4.icanhazip.com"

  # Optional request headers
  request_headers {
    "Accept" = "application/json"
  }
}


resource "aws_security_group" "security_group" {
  name = "${var.project}_app_sg"
  description = "Allow Limited Access to Postgres Target"
  vpc_id = "${var.vpc_id}"

  ingress {
      from_port = 22
      to_port = 22
      protocol = "tcp"
      cidr_blocks = ["${chomp("${data.http.your_ip.body}")}/32"]
  }

  ingress {
      from_port = 80
      to_port = 80
      protocol = "tcp"
      cidr_blocks = ["${chomp("${data.http.your_ip.body}")}/32"]
  }

  ingress {
      from_port = 8080
      to_port = 8080
      protocol = "tcp"
      cidr_blocks = ["${chomp("${data.http.your_ip.body}")}/32"]
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
    Name = "${var.project}_app_sg"
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
    Name = "${var.project}_app"
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
  triggers {
    new_id = "${uuid()}"
  }
  provisioner "local-exec" {
    command = "sed -i '' -e 's#spring.datasource.url=.*#spring.datasource.url=jdbc:postgresql://${var.db_url}:5434/${data.aws_kms_secrets.db.plaintext["name"]}#g' ../src/main/resources/application.properties"
  }
  provisioner "local-exec" {
    command = "sed -i '' -e 's/spring.datasource.username=.*/spring.datasource.username=${data.aws_kms_secrets.db.plaintext["user"]}/g' ../src/main/resources/application.properties"
  }
  provisioner "local-exec" {
    command = "sed -i '' -e 's/spring.datasource.password=.*/spring.datasource.password=${data.aws_kms_secrets.db.plaintext["pass"]}/g' ../src/main/resources/application.properties"
  }
  provisioner "local-exec" {
    command = "sed -i '' -e 's/jwt.secret=.*/jwt.secret=${data.aws_kms_secrets.db.plaintext["jwt"]}/g' ../src/main/resources/application.properties"
  }
  provisioner "local-exec" {
    command = "sed -i '' -e 's/localhost/${aws_instance.web_server.public_ip}/g' ../client/src/environments/environment.prod.ts"
  }
  provisioner "local-exec" {
    command = "ansible-playbook -e public_ip='${aws_instance.web_server.public_ip}' deploy.yaml -vvv"
  }
}
