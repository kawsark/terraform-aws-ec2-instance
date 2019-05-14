variable "aws_region" {
  description = "AWS region"
  default     = "us-east-2"
}

variable "vault_license" {
  description = "enter a Vault Enterprise license here "
}

variable "consul_license" {
  description = "enter a Consul Enterprise license here "
}

variable "owner" {
  default = "demouser"
}

variable "consul_dc" {
  default = "dc1"
}

variable "consul_server_count" {
  default = 3
}

variable "private_ip_map" {
  type = "map"
  default = {
    n1 = "192.168.0.10"
    n2 = "192.168.8.10"
    n3 = "192.168.16.10"
    n4 = "192.168.0.11"
    n5 = "192.168.8.11"
    n6 = "192.168.16.11"
  }
}

variable "key_name" {}

variable "security_group_ingress" {
  description = "Ingress CIDR to allow SSH and Hashistack access. Warning: setting 0.0.0.0/0 is a bad idea as this deployment does not use TLS."
}

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

variable "public_subnet_3_block" {
  default = "192.168.16.0/21"
}

