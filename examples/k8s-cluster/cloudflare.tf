# Add the server record to domain
resource "cloudflare_record" "k8s-master" {
  count  = "${var.create_cloudflare_dns}"
  domain = "${var.cloudflare_domain}"
  name   = "k8s"
  value  = "${module.aws-kubernetes.public_dns[0]}"
  type   = "CNAME"
  ttl    = 1
}

resource "cloudflare_record" "k8s-workers" {
  count = "${var.create_cloudflare_dns == "0" ? 0 : var.cluster_size - 1}"
  count  = "${var.create_cloudflare_dns}"
  domain = "${var.cloudflare_domain}"
  name   = "k8s-${count.index+1}"
  value  = "${module.aws-kubernetes.public_dns[count.index + 1]}"
  type   = "CNAME"
  ttl    = 1
}

output "cloudflare_master_dns" {
  value = "${cloudflare_record.k8s-master.*.hostname}"
}

output "cloudflare_worker_dns" {
  value = "${cloudflare_record.k8s-workers.*.hostname}"
}
