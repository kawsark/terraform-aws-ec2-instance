# Add the server record to domain
resource "random_pet" "server" {

}

resource "cloudflare_record" "vault_server" {
  count  = "${var.create_cloudflare_dns}"
  domain = "${var.cloudflare_domain}"
  name   = "${random_pet.server.id}-vault-pri"
  value  = "${module.vault-server.public_dns[0]}"
  type   = "CNAME"
  ttl    = 1
}

resource "cloudflare_record" "vault_server_secondary" {
  count  = "${var.create_cloudflare_dns}"
  domain = "${var.cloudflare_domain}"
  name   = "${random_pet.server.id}-vault-sec"
  value  = "${module.vault-server-secondary.public_dns[0]}"
  type   = "CNAME"
  ttl    = 1
}

output "vault_dns" {
  value = "${cloudflare_record.vault_server.*.hostname}"
}

output "vault_dns_secondary" {
  value = "${cloudflare_record.vault_server_secondary.*.hostname}"
}