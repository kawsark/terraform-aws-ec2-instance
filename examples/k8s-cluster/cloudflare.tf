# Add the server record to domain
resource "cloudflare_record" "aws-kubernetes" {
  count  = "${var.create_cloudflare_dns}"
  domain = "${var.cloudflare_domain}"
  name   = "k8s"
  value  = "${module.aws-kubernetes.public_dns[0]}"
  type   = "CNAME"
  ttl    = 1
}