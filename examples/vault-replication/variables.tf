variable "aws_region" {
  description = "AWS region for Primary Vault server"
  default     = "us-east-2"
}

variable "aws_region_secondary" {
  description = "AWS region for Secondary Vault server"
  default     = "us-west-1"
}

variable "owner" {
  description = "A value for the owner tag"
  default     = "demouser"
}

variable "ttl" {
  description = "A value for the ttl tag"
  default     = "48"
}

variable "key_name" {}

variable "key_name_secondary" {}

variable "security_group_ingress" {
  description = "Ingress CIDR to allow SSH and Hashistack access. Warning: setting 0.0.0.0/0 is a bad idea as this deployment does not use TLS."
  type = "list"
}

variable "environment" {
  default = "demo"
}

variable "vault_url" {
  description = "URL to download vault from, nter a Vault Enterprise URL here "
}

variable "vault_license" {
  description = "enter a Vault Enterprise license here "
}

variable "consul_url" {
  description = "URL to download vault from, enter a Consul Enterprise URL here "
}

variable "consul_license" {
  description = "enter a Consul Enterprise license here "
}


# Optionally create a Cloudflare DNS record
# Note: enabling this will require CLOUDFLARE_EMAIL and CLOUDFLARE_TOKEN
variable "create_cloudflare_dns" {
  description = "If set to 1, attempts to create a CNAME record with server public DNS"
  default = "0"
}

variable "cloudflare_domain" {
  description = "If create_cloudflare_dns is set to 1, then set the root domain appropriately"
  default = "example.com"
}
  
