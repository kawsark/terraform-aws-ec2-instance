module "sqs" {
  source  = "app.terraform.io/kawsar-org/sqs/aws"

#  source  = "terraform-aws-modules/sqs/aws"
  version = "<= 1.2.1"

 name = "kawsar-sqs-module-test"

  tags = {
    owner     = "kawsar@hashicorp.com"
    ttl       = "48h"
    Environment = "dev"
  }
}