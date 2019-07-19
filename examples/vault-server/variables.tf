variable "aws_region" {
  description = "AWS region"
  default     = "us-east-2"
}

variable "owner" {
  description = "A value for the owner tag"
  default     = "demouser"
}

variable "ttl" {
  description = "A value for the ttl tag"
  default     = "48"
}

variable "key_name" {
}

variable "security_group_ingress" {
  description = "Ingress CIDR to allow SSH and Hashistack access. Warning: setting 0.0.0.0/0 is a bad idea as this deployment does not use TLS."
  type        = list(string)
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

variable "vault_version" {
  description = "Version of Vault binary to download"
  default     = "1.1.3"
}

variable "consul_version" {
  description = "Version of Consul binary to download"
  default     = "1.5.2"
}

# Optionally create a Cloudflare DNS record
# Note: enabling this will require CLOUDFLARE_EMAIL and CLOUDFLARE_TOKEN
variable "create_cloudflare_dns" {
  description = "If set to 1, attempts to create a CNAME record with server public DNS"
  default     = "0"
}

variable "cloudflare_domain" {
  description = "If create_cloudflare_dns is set to 1, then set the root domain appropriately"
  default     = "example.com"
}

