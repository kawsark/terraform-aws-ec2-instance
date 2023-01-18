provider "aws" {
  region = local.region
}

locals {
  region            = var.aws_region
  availability_zone = "${local.region}a"
  name              = "bastion_tf"
  name_private      = "app_tf"
  tags = {
    Owner       = "user"
    Environment = "dev"
  }
}

# AMI
data "aws_ami" "ubuntu" {
  # Canonical = 099720109477
  owners      = ["099720109477"]
  most_recent = "true"

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}

################################################################################
# EC2 Module - public facing
################################################################################

module "ec2" {
  source = "terraform-aws-modules/ec2-instance/aws"

  name = local.name

  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  availability_zone           = local.availability_zone
  subnet_id                   = var.subnet_id_public
  vpc_security_group_ids      = var.security_group_ids
  associate_public_ip_address = true
  user_data                   = templatefile("${path.module}/userdata.sh.tpl", { GO_VERSION = var.go_sdk_version, SSH_KEY = var.ssh_public_key })
  user_data_replace_on_change = true

  root_block_device = [
    {
      encrypted   = true
      volume_type = "gp3"
      throughput  = 200
      volume_size = 50
    },
  ]

  tags = local.tags
}

resource "aws_volume_attachment" "this" {
  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.this.id
  instance_id = module.ec2.id
}

resource "aws_ebs_volume" "this" {
  availability_zone = local.availability_zone
  size              = 20

  tags = local.tags
}


################################################################################
# EC2 Module - private facing
################################################################################

/* module "ec2_private" {
  source = "terraform-aws-modules/ec2-instance/aws"

  name = local.name_private

  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  availability_zone           = local.availability_zone
  subnet_id                   = var.subnet_id_private
  vpc_security_group_ids      = var.security_group_ids
  associate_public_ip_address = true
  user_data                   = templatefile("${path.module}/userdata.sh.tpl", { GO_VERSION = var.go_sdk_version, SSH_KEY = var.ssh_public_key })
  user_data_replace_on_change = true

  tags = local.tags
}

resource "aws_volume_attachment" "ebs_private_at" {
  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.ebs_private.id
  instance_id = module.ec2_private.id
}

resource "aws_ebs_volume" "ebs_private" {
  availability_zone = local.availability_zone
  size              = 1

  tags = local.tags
} */