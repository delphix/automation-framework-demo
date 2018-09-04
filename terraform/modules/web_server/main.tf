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

resource "null_resource" "deploy_daf_app_stack" {
  provisioner "local-exec" {
    command = "sed -i '' -e 's/localhost/${aws_instance.web_server.public_ip}/g' ../client/src/environments/environment.prod.ts"
  }
  provisioner "local-exec" {
    command = "ansible-playbook -e public_ip='${aws_instance.web_server.public_ip}' deploy.yaml -vvv"
  }
}
