terraform {
  backend "remote" {
    hostname = "app.terraform.io"
    organization = "kawsar-org"

    workspaces {
      name = "102518-terraform-aws-ec2-instance"
    }
  }
}
