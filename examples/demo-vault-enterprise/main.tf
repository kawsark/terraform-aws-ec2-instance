provider "aws" {
  region = "${var.aws_region}"
}

# Consul server 1
module "n1" {
  source    = "../../"
  name      = "consul-n1"
  owner     = "${var.owner}"
  ami_id    = "${data.aws_ami.consul.id}"
  count     = "1"
  key_name  = "${var.key_name}"
  user_data = "${data.template_file.n1_userdata.rendered}"
  subnet_id = "${aws_subnet.mvd-public-1.id}"
  sg_ids    = ["${aws_security_group.mvd-sg.id}"]
  private_ip = "${lookup(var.private_ip_map,"n1")}"
  sequence = "0"
}

# Consul server 2
module "n2" {
  source    = "../../"
  name      = "consul-n2"
  owner     = "${var.owner}"
  ami_id    = "${data.aws_ami.consul.id}"
  count     = "1"
  key_name  = "${var.key_name}"
  user_data = "${data.template_file.n2_userdata.rendered}"
  subnet_id = "${aws_subnet.mvd-public-2.id}"
  sg_ids     = ["${aws_security_group.mvd-sg.id}"]
  private_ip = "${lookup(var.private_ip_map,"n2")}"
  sequence = "${module.n1.id}"
}

# Consul server 3
module "n3" {
  source    = "../../"
  name      = "consul-n3"
  owner     = "${var.owner}"
  ami_id    = "${data.aws_ami.consul.id}"
  count     = "1"
  key_name  = "${var.key_name}"
  user_data = "${data.template_file.n3_userdata.rendered}"
  subnet_id = "${aws_subnet.mvd-public-3.id}"
  sg_ids     = ["${aws_security_group.mvd-sg.id}"]
  private_ip = "${lookup(var.private_ip_map,"n3")}"
  sequence = "${module.n2.id}"
}

# Vault server 1
module "n4" {
  source    = "../../"
  name      = "vault-n4"
  ami_id    = "${data.aws_ami.vault.id}"
  owner     = "${var.owner}"
  count     = "1"
  key_name  = "${var.key_name}"
  user_data = "${data.template_file.n4_userdata.rendered}"
  subnet_id = "${aws_subnet.mvd-public-1.id}"
  sg_ids    = ["${aws_security_group.mvd-sg.id}"]
  private_ip = "${lookup(var.private_ip_map,"n4")}"
  sequence = "${module.n3.id}"
}

# Vault server 2
module "n5" {
  source    = "../../"
  name      = "vault-n5"
  ami_id    = "${data.aws_ami.vault.id}"
  owner     = "${var.owner}"
  count     = "1"
  key_name  = "${var.key_name}"
  user_data = "${data.template_file.n5_userdata.rendered}"
  subnet_id = "${aws_subnet.mvd-public-2.id}"
  sg_ids    = ["${aws_security_group.mvd-sg.id}"]
  private_ip = "${lookup(var.private_ip_map,"n5")}"
  sequence = "${module.n4.id}"
}
