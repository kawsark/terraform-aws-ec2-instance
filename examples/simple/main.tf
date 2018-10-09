variable "owner" {
  default = "demouser"
}

data "template_file" "init" {
  template = "${file("user-data.tpl")}"

  vars {
    owner = "${var.owner}"
  }
}

module "ubuntu-user-data" {
  source = "../../"
  owner  = "${var.owner}"
  count  = "1"
}
