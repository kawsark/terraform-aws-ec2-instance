provider "aws" {
  region = "${var.aws_region}"
}

# Render userdata
data "template_file" "startup_script" {
  template = "${file("${path.module}/k8s-user-data.sh.tpl")}"

  vars {
    DOCKER_VERSION = "${var.docker_version}"
  }
}

# K8S cluster
module "aws-kubernetes" {
  source     	 = "github.com/kawsark/terraform-aws-ec2-instance?ref=userdata"
  instance_type  = "t2.medium"
  name       = "aws-kubernetes"
  ami_id     = "${var.ami_id}"
  owner      = "${var.owner}"
  ttl        = "${var.ttl}"
  count      = "${var.cluster_size}"
  key_name   = "${var.key_name}"
  user_data  = "${data.template_file.startup_script.rendered}"
  subnet_id  = "${aws_subnet.mvd-public-1.id}"
  sg_ids     = ["${aws_security_group.mvd-sg.id}"]
  sequence   = "0"
}

output "public_dns" {
  value = "${module.aws-kubernetes.public_dns}"
}
