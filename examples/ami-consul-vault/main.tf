provider "aws" {
  region = "${var.aws_region}"
}

# Render userdata
data "template_file" "startup_script" {
  template = "${file("${path.module}/vault-consul-ami-rc.sh.tpl")}"

  vars {
    CONSUL_VERSION = "${var.consul_version}"
    VAULT_VERSION  = "${var.vault_version}"
  }
}

# vault server 1
module "vault-server" {
  source     = "github.com/kawsark/terraform-aws-ec2-instance?ref=userdata"
  ami_id     = "${var.ami_id}"
  aws_region = "${var.aws_region}"
  name       = "demo-vault-server"
  owner      = "${var.owner}"
  ttl        = "${var.ttl}"
  count      = "1"
  key_name   = "${var.key_name}"
  user_data  = "${data.template_file.startup_script.rendered}"
  subnet_id  = "${aws_subnet.mvd-public-1.id}"
  sg_ids     = ["${aws_security_group.mvd-sg.id}"]
  sequence   = "0"
}

output "public_dns" {
  value = "${module.vault-server.public_dns}"
}
