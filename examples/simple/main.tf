variable "owner" {
  default = "demouser"
}

module "demo-server" {
  source = "github.com/kawsark/terraform-aws-ec2-instance"
  owner  = "${var.owner}"
  count  = "1"
}
