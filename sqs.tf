module "sqs" {
  source  = "terraform-aws-modules/sqs/aws"
  version = "1.2.0"

 name = "kawsar-sqs-module-test"

  tags = {
    owner     = "kawsar@hashicorp.com"
    ttl       = "48h"
    Environment = "dev"
  }
}