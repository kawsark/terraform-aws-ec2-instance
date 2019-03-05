output "public_dns" {
  value = "${aws_instance.demo_server.*.public_dns}"
}

output "id" {
  value = "${aws_instance.demo_server.0.id}"
}
