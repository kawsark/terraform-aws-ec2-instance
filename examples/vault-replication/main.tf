provider "aws" {
  region = "${var.aws_region}"
}

provider "aws" {
  region = "${var.aws_region_secondary}"
  alias = "aws_secondary"
}

# Render userdata
data "template_file" "startup_script" {
  template = "${file("${path.module}/vault-consul.sh.tpl")}"

  vars {
    region = "${var.aws_region}"
    vault_url  = "${var.vault_url}"
    vault_license = "${var.vault_license}"
    consul_url  = "${var.consul_url}"
    consul_license = "${var.consul_license}"
  }
}

# Primary network
module "vpc" {
  source = "modules/vpc"
  aws_region = "${var.aws_region}"
  owner = "${var.owner}"
  environment = "${var.environment}"
  security_group_ingress = "${var.security_group_ingress}"
}

# Primary vault server
module "vault-server" {
#  source     = "github.com/kawsark/terraform-aws-ec2-instance?ref=userdata"
  source = "../../"
  name       = "primary-vault-server"
  ami_id     = "${data.aws_ami.ubuntu.id}"
  owner      = "${var.owner}"
  ttl        = "${var.ttl}"
  count      = "1"
  key_name   = "${var.key_name}"
  user_data  = "${data.template_file.startup_script.rendered}"
  subnet_id  = "${module.vpc.public-subnet-id}"
  sg_ids     = ["${module.vpc.security-group-id}"]
  sequence   = "0"
}

# Secondary network
module "vpc-secondary" {
  source = "modules/vpc"
  aws_region = "${var.aws_region_secondary}"
  providers = {
    aws = "aws.aws_secondary"
  }
  owner = "${var.owner}"
  environment = "${var.environment}"
  security_group_ingress = "${var.security_group_ingress}"
}

# Secondary vault server
module "vault-server-secondary" {
  aws_region = "${var.aws_region_secondary}"
  providers = {
    aws = "aws.aws_secondary"
  }
#  source     = "github.com/kawsark/terraform-aws-ec2-instance?ref=userdata"
  source = "../../"
  name       = "secondary-vault-server"
  ami_id     = "${data.aws_ami.ubuntu_secondary.id}"
  owner      = "${var.owner}"
  ttl        = "${var.ttl}"
  count      = "1"
  key_name   = "${var.key_name_secondary}"
  user_data  = "${data.template_file.startup_script.rendered}"
  subnet_id  = "${module.vpc-secondary.public-subnet-id}"
  sg_ids     = ["${module.vpc-secondary.security-group-id}"]
  sequence   = "0"
}

output "public_dns" {
  value = "${module.vault-server.public_dns}"
}

output "public_dns_secondary" {
  value = "${module.vault-server-secondary.public_dns}"
}
