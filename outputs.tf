output "public_dns" {
  value = "${aws_instance.ubuntu.*.public_dns}"
}

output "id" {
  value = "${aws_instance.ubuntu.*.id}"
}
