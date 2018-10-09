variable "aws_region" {
  description = "AWS region"
  default     = "us-east-2"
}

variable "owner" {
  default = "demouser"
}

variable "private_ip_map" {
  type = "map"
  default = {
    n1 = "192.168.0.10"
    n2 = "192.168.0.11"
    n3 = "192.168.0.12"
    n4 = "192.168.0.13"
    n5 = "192.168.0.14"
    n6 = "192.168.0.15"
  }
}

variable "key_name" {}

variable "security_group_ingress" {}

variable "environment" {
  default = "demo"
}

variable "vpc_cidr_block" {
  default = "192.168.0.0/16"
}

variable "public_subnet_1_block" {
  default = "192.168.0.0/21"
}

variable "public_subnet_2_block" {
  default = "192.168.8.0/21"
}


