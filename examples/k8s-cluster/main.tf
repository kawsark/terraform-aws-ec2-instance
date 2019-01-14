provider "aws" {
  region = "${var.aws_region}"
}

# Render userdata
data "http" "k8s-user-data" {
  url = "https://gist.githubusercontent.com/initcron/40b71211cb693f541ce35fe3fb1adb11/raw/e1db293bbef340eec9067e096f010a591cd674c5/k8s-user-data.sh"
}

# K8S cluster
module "aws-kubernetes" {
  source     = "github.com/kawsark/terraform-aws-ec2-instance?ref=userdata"
  name       = "aws-kubernetes"
  ami_id     = "${var.ami_id}"
  owner      = "${var.owner}"
  ttl        = "${var.ttl}"
  count      = "3"
  key_name   = "${var.key_name}"
  user_data  = "${data.http.k8s-user-data.body}"
  subnet_id  = "${aws_subnet.mvd-public-1.id}"
  sg_ids     = ["${aws_security_group.mvd-sg.id}"]
  sequence   = "0"
}

output "public_dns" {
  value = "${module.aws-kubernetes.public_dns}"
}
