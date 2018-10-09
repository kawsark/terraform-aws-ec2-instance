provider "aws" {
  region = "${var.aws_region}"
}

module "n1" {
  source    = "../../"
  name      = "n1"
  owner     = "${var.owner}"
  count     = "1"
  key_name  = "${var.key_name}"
  user_data = "${file("scripts/user-data-n1.sh")}"
  subnet_id = "${aws_subnet.mvd-public-1.id}"
  sg_ids    = ["${aws_security_group.mvd-sg.id}"]
  private_ip = "${lookup(var.private_ip_map,"n1")}"
}

module "n2" {
  source    = "../../"
  owner     = "${var.owner}"
  count     = "1"
  key_name  = "${var.key_name}"
  user_data = "${file("scripts/user-data-n2.sh")}"
  subnet_id = "${aws_subnet.mvd-public-1.id}"
  sg_ids     = ["${aws_security_group.mvd-sg.id}"]
  private_ip = "${lookup(var.private_ip_map,"n2")}"
}

module "n3" {
  source    = "../../"
  owner     = "${var.owner}"
  count     = "1"
  key_name  = "${var.key_name}"
  user_data = "${file("scripts/user-data-n3.sh")}"
  subnet_id = "${aws_subnet.mvd-public-1.id}"
  sg_ids     = ["${aws_security_group.mvd-sg.id}"]
  private_ip = "${lookup(var.private_ip_map,"n3")}"
}

module "n4" {
  source    = "../../"
  owner     = "${var.owner}"
  count     = "1"
  key_name  = "${var.key_name}"
  user_data = "${file("scripts/user-data-n4.sh")}"
  subnet_id = "${aws_subnet.mvd-public-1.id}"
  sg_ids    = ["${aws_security_group.mvd-sg.id}"]
  private_ip = "${lookup(var.private_ip_map,"n4")}"
}
