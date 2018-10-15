# Add the server record to domain
resource "cloudflare_record" "vault_server" {
  count  = "${var.create_cloudflare_dns}"
  domain = "${var.cloudflare_domain}"
  name   = "vault"
  value  = "${module.vault-server.public_dns[0]}"
  type   = "CNAME"
  ttl    = 1
}