terraform {
  backend "s3" {
    bucket = "kawsar-tfstate-061318"
    key    = "git/kawsark/terraform-aws-ec2-instance/"
    region = "us-east-2"
  }
}