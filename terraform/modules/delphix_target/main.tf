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
  name = "${var.project}_postgres_ec2"
  description = "Allow Limited Access to Postgres Target"
  vpc_id = "${var.vpc_id}"

  ingress {
      from_port = 22
      to_port = 22
      protocol = "tcp"
      cidr_blocks = ["${chomp("${data.http.your_ip.body}")}/32"]
  }

  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    self = true
  }

  ingress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      security_groups = ["${var.de_security_group}"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "${var.project}_postgres_ec2"
    "dlpx:Project" = "${var.project}"
    "dlpx:Owner" = "${var.owner}"
    "dlpx:Expiration" = "${var.expiration}"
    "dlpx:CostCenter" = "${var.cost_center}"
  }
}

output "security_group_id" {
    value = "${aws_security_group.security_group.id}"
}


resource "aws_instance" "target" {
  ami = "${data.aws_ami.delphix-ready-ami.id}"
  instance_type = "t2.medium"
  key_name = "${var.key_name}"

  vpc_security_group_ids = ["${aws_security_group.security_group.id}"]
  subnet_id = "${var.subnet_id}"

  root_block_device {
    volume_type           = "gp2"
    volume_size           = "50"
    delete_on_termination = "true"
  }

  #Instance tags
  tags {
    Name = "${var.project}_dms_source"
    "dlpx:Project" = "${var.project}"
    "dlpx:Owner" = "${var.owner}"
    "dlpx:Expiration" = "${var.expiration}"
    "dlpx:CostCenter" = "${var.cost_center}"
  }
}

output "public_ip" {
  value = "${aws_instance.target.public_ip}"
}

output "instance_id" {
  value = "${aws_instance.target.id}"
}

output "private_ip" {
  value = "${aws_instance.target.private_ip}"
}

/*
data "template_file" "user_data_shell" {
  template = <<-EOF
    #!/bin/bash
    mkdir /var/lib/pgsql/.ssh
    echo "`dig +short ${aws_db_instance.default.address}` rdshost ${aws_db_instance.default.address}" >> /etc/hosts
    curl http://169.254.169.254/latest/meta-data/public-keys/0/openssh-key > /var/lib/pgsql/.ssh/authorized_keys
    chown -R oracle.oinstall /home/oracle/.ssh
    chmod 700 /var/lib/pgsql/.ssh
    chmod 600 /var/lib/pgsql/.ssh/authorized_keys
    EOF
}
*/
