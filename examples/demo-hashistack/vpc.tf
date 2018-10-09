# Internet VPC
resource "aws_vpc" "mvd_vpc" {
  cidr_block           = "${var.vpc_cidr_block}"
  instance_tenancy     = "default"
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"

  tags {
    Name  = "mvd_vpc"
    owner = "${var.owner}"
    Env   = "${var.environment}"
  }
}

# Subnets
resource "aws_subnet" "mvd-public-1" {
  vpc_id                  = "${aws_vpc.mvd_vpc.id}"
  cidr_block              = "${var.public_subnet_1_block}"
  map_public_ip_on_launch = "true"
  availability_zone       = "${format("%sa",var.aws_region)}"

  tags {
    Name  = "mvd-public-1"
    owner = "${var.owner}"
    Env   = "${var.environment}"
  }
}

resource "aws_subnet" "mvd-public-2" {
  vpc_id                  = "${aws_vpc.mvd_vpc.id}"
  cidr_block              = "${var.public_subnet_2_block}"
  map_public_ip_on_launch = "true"
  availability_zone       = "${format("%sb",var.aws_region)}"

  tags {
    Name  = "mvd-public-2"
    owner = "${var.owner}"
    Env   = "${var.environment}"
  }
}

# Internet GW
resource "aws_internet_gateway" "mvd-gw" {
  vpc_id = "${aws_vpc.mvd_vpc.id}"

  tags {
    Name  = "mvd-gw"
    owner = "${var.owner}"
    Env   = "${var.environment}"
  }
}

#Public route table with IGW
resource "aws_route_table" "mvd-public" {
  vpc_id = "${aws_vpc.mvd_vpc.id}"

  tags {
    Name  = "mvd-public-1"
    owner = "${var.owner}"
    Env   = "${var.environment}"
  }
}

#Public route
resource "aws_route" "mvd-public-route" {
  route_table_id         = "${aws_route_table.mvd-public.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.mvd-gw.id}"
}

# route associations public
resource "aws_route_table_association" "mvd-public-1-a" {
  subnet_id      = "${aws_subnet.mvd-public-1.id}"
  route_table_id = "${aws_route_table.mvd-public.id}"
}

resource "aws_route_table_association" "mvd-public-2-a" {
  subnet_id      = "${aws_subnet.mvd-public-2.id}"
  route_table_id = "${aws_route_table.mvd-public.id}"
}

resource "aws_security_group" "mvd-sg" {
  vpc_id      = "${aws_vpc.mvd_vpc.id}"
  description = "security group that allows ssh and all egress traffic"

  tags {
    Name  = "mvd-sg"
    owner = "${var.owner}"
    Env   = "${var.environment}"
  }
}

resource "aws_security_group_rule" "egress_allow_all" {
  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = "${aws_security_group.mvd-sg.id}"
}

resource "aws_security_group_rule" "ingress_allow_ssh" {
  type        = "ingress"
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  cidr_blocks = ["${var.security_group_ingress}"]
  security_group_id = "${aws_security_group.mvd-sg.id}"
}

resource "aws_security_group_rule" "allow_cluster_inbound_from_self" {
  type      = "ingress"
  from_port = "0"
  to_port   = "0"
  protocol  = "-1"
  self      = true

  security_group_id = "${aws_security_group.mvd-sg.id}"
}