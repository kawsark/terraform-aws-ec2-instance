provider "aws" {
  region = "${var.aws_region}"
}

# Render userdata
data "template_file" "startup_script" {
  template = "${file("${path.module}/vault-consul.sh.tpl")}"
  vars{
    CONSUL_VERSION = "${var.consul_version}"
    VAULT_VERSION = "${var.vault_version}"
  }
}

# Consul server 1
module "vault-server" {
  source    = "github.com/kawsark/terraform-aws-ec2-instance?ref=userdata"
  name      = "demo-vault-server"
  owner     = "${var.owner}"
  ttl	    = "168"
  count     = "1"
  key_name  = "${var.key_name}"
  user_data = "${data.template_file.startup_script.rendered}"
  subnet_id = "${aws_subnet.mvd-public-1.id}"
  sg_ids    = ["${aws_security_group.mvd-sg.id}"]
  private_ip = "${lookup(var.private_ip_map,"n1")}"
  sequence = "0"
}

output "public_dns" {
  value = "${module.vault-server.public_dns}"
}

