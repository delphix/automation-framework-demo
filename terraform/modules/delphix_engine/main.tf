data "aws_ami" "de_ami" {
  most_recent = true
  filter {
    name = "name"
    values = ["Delphix Engine 5.2.*"]
  }

  #From Delphix
  owners = ["180093685553"]
}

resource "aws_subnet" "server_sub" {
    vpc_id = "${var.vpc_id}"
    cidr_block = "${var.server_network}"
    map_public_ip_on_launch = true

    tags {
        Name = "${var.project}_sub"
        "dlpx:Project" = "${var.project}"
        "dlpx:Owner" = "${var.owner}"
        "dlpx:Expiration" = "${var.expiration}"
        "dlpx:CostCenter" = "${var.cost_center}"
    }
}

output "subnet_id" {
    value = "${aws_subnet.server_sub.id}"
}

resource "aws_security_group" "security_group" {
  name = "${var.project}_Delphix_Engine"
  description = "Allow all inbound traffic"
  vpc_id = "${var.vpc_id}"

  ingress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["10.0.0.0/16"]
  }

  ingress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = "${var.static_ips}"
  }

  ingress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      security_groups = ["${var.jenkins_sg}"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "${var.project}_delphix_engine"
    "dlpx:Project" = "${var.project}"
    "dlpx:Owner" = "${var.owner}"
    "dlpx:Expiration" = "${var.expiration}"
    "dlpx:CostCenter" = "${var.cost_center}"
  }

}

output "security_group_id" {
    value = "${aws_security_group.security_group.id}"
}

resource "aws_instance" "de" {
  instance_type = "t2.medium"
  # Lookup the correct AMI based on the region
  # we specified
  ami = "${data.aws_ami.de_ami.id}"

  key_name = "${var.key_name}"

  # Our Security group to allow HTTP and SSH access
  vpc_security_group_ids = ["${aws_security_group.security_group.id}"]

  subnet_id = "${aws_subnet.server_sub.id}"

  ebs_block_device {
        device_name = "/dev/sdb"
        volume_type = "gp2"
        volume_size = "2"
        delete_on_termination = true

    }
  ebs_block_device {
        device_name = "/dev/sdc"
        volume_type = "gp2"
        volume_size = "2"
        delete_on_termination = true

    }
  ebs_block_device {
        device_name = "/dev/sdd"
        volume_type = "gp2"
        volume_size = "2"
        delete_on_termination = true

    }
  #Instance tags
  tags {
    Name = "${var.project}_DE"
    "dlpx:Project" = "${var.project}"
    "dlpx:Owner" = "${var.owner}"
    "dlpx:Expiration" = "${var.expiration}"
    "dlpx:CostCenter" = "${var.cost_center}"
  }
}

output "public_ip" {
  value = "${aws_instance.de.public_ip}"
}

output "private_ip" {
  value = "${aws_instance.de.private_ip}"
}
