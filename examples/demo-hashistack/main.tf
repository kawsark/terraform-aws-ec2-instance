provider "aws" {
  region = "${var.aws_region}"
}

# Consul server 1
module "n1" {
  source    = "../../"
  name      = "demo-hashistack-n1"
  owner     = "${var.owner}"
  count     = "1"
  key_name  = "${var.key_name}"
  user_data = "${file("scripts/user-data-n1.sh")}"
  subnet_id = "${aws_subnet.mvd-public-1.id}"
  sg_ids    = ["${aws_security_group.mvd-sg.id}"]
  private_ip = "${lookup(var.private_ip_map,"n1")}"
  sequence = "0"
}

# Consul server 2
module "n2" {
  source    = "../../"
  name      = "demo-hashistack-n2"
  owner     = "${var.owner}"
  count     = "1"
  key_name  = "${var.key_name}"
  user_data = "${file("scripts/user-data-n2.sh")}"
  subnet_id = "${aws_subnet.mvd-public-1.id}"
  sg_ids     = ["${aws_security_group.mvd-sg.id}"]
  private_ip = "${lookup(var.private_ip_map,"n2")}"
  sequence = "${module.n1.id}"
}

# Nomad client 1
module "n3" {
  source    = "../../"
  name      = "demo-hashistack-n3"
  owner     = "${var.owner}"
  count     = "1"
  key_name  = "${var.key_name}"
  user_data = "${file("scripts/user-data-n3.sh")}"
  subnet_id = "${aws_subnet.mvd-public-1.id}"
  sg_ids     = ["${aws_security_group.mvd-sg.id}"]
  private_ip = "${lookup(var.private_ip_map,"n3")}"
  sequence = "${module.n4.id}"
}

# Nomad server 1
module "n4" {
  source    = "../../"
  name      = "demo-hashistack-n4"
  owner     = "${var.owner}"
  count     = "1"
  key_name  = "${var.key_name}"
  user_data = "${file("scripts/user-data-n4.sh")}"
  subnet_id = "${aws_subnet.mvd-public-1.id}"
  sg_ids    = ["${aws_security_group.mvd-sg.id}"]
  private_ip = "${lookup(var.private_ip_map,"n4")}"
  sequence = "${module.n6.id}"
}

# Vault server 1
module "n5" {
  source    = "../../"
  name      = "demo-hashistack-n5"
  owner     = "${var.owner}"
  count     = "1"
  key_name  = "${var.key_name}"
  user_data = "${file("scripts/user-data-n5.sh")}"
  subnet_id = "${aws_subnet.mvd-public-1.id}"
  sg_ids    = ["${aws_security_group.mvd-sg.id}"]
  private_ip = "${lookup(var.private_ip_map,"n5")}"
  sequence = "${module.n2.id}"
}

# Vault server 2
module "n6" {
  source    = "../../"
  name      = "demo-hashistack-n6"
  owner     = "${var.owner}"
  count     = "1"
  key_name  = "${var.key_name}"
  user_data = "${file("scripts/user-data-n6.sh")}"
  subnet_id = "${aws_subnet.mvd-public-1.id}"
  sg_ids    = ["${aws_security_group.mvd-sg.id}"]
  private_ip = "${lookup(var.private_ip_map,"n6")}"
  sequence = "${module.n5.id}"
}
