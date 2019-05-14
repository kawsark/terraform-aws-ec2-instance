output "consul_0" {
 value = "${module.n1.public_dns}"
}
output "consul_1" {
 value = "${module.n2.public_dns}"
}
output "consul_2" {
 value = "${module.n3.public_dns}"
}
output "vault_0" {
 value = "${module.n4.public_dns}"
}
output "vault_1" {
 value = "${module.n5.public_dns}"
}