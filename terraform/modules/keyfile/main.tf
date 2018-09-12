data "aws_kms_secrets" "pem" {
  secret {
    name    = "pem"
    payload = "${var.pem}"
  }
}

resource "local_file" "pem" {
    content     = "${data.aws_kms_secrets.pem.plaintext["pem"]}"
    filename = "./inventory/ansible-deploy-key.pem"
}

resource "null_resource" "chmod" {
  triggers {
    new_id = "${uuid()}"
  }
  provisioner "local-exec" {
    command = "chmod 400 ./inventory/ansible-deploy-key.pem"
  }
}
