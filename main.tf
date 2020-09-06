provider "aws" {
  region = var.aws_region
}

resource "aws_instance" "ubuntu" {
  count             = var.num_servers
  ami               = var.ami_id
  instance_type     = var.instance_type
  availability_zone = "${var.aws_region}a"
  key_name          = var.key_name

  tags = {
    Name  = "${var.name}-${count.index}"
    owner = var.owner
    ttl   = var.ttl
  }
}

