provider "aws" {
  region = "${var.aws_region}"
}

resource "aws_instance" "demo_server" {
  count             = "${var.count}"
  ami               = "${var.ami_id}"
  instance_type     = "${var.instance_type}"

  tags {
    Name  = "${var.name}-${count.index}"
    owner = "${var.owner}"
    TTL   = "${var.ttl}"
    sequence = "${var.sequence}"
  }

  user_data = "${var.user_data}"
  key_name  = "${var.key_name}"
  subnet_id = "${var.subnet_id}"

  # https://github.com/hashicorp/terraform/issues/13869
  vpc_security_group_ids = ["${var.sg_ids}"]
}
