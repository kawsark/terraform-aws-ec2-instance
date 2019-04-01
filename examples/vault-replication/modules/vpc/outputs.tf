output "public-subnet-id" {
  value = "${aws_subnet.mvd-public-1.id}"
}

output "security-group-id" {
  value = "${aws_security_group.mvd-sg.id}"
}