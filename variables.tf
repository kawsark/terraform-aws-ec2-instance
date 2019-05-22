variable "aws_region" {
  description = "AWS region"
  default     = "us-east-2"
}

variable "iam_instance_profile_name" {
  description = "Instance profile name"
  default = ""
}

variable "ami_id" {
  description = "ID of the AMI to provision. Default is Ubuntu 16.04 Base Image in us-east-2"
  default     = "ami-0552e3455b9bc8d50"
}

variable "count" {
  description = "How many servers to provision"
  default     = 1
}

variable "instance_type" {
  description = "type of EC2 instance to provision."
  default     = "t2.micro"
}

variable "name" {
  description = "name to pass to Name tag"
  default     = "terraform-ubuntu"
}

variable "owner" {
  description = "An Owner tag"
}

variable "app" {
  description = "Optional application tag"
  default = "terraform-app"
}

variable "namespace" {
  description = "Optional project tag"
  default = "demo"
}

variable "key_name" {
  description = "Existing key in region"
}

variable "ttl" {
  description = "A desired time to live (not enforced via terraform)"
  default     = "48"
}

variable "user_data" {
  description = "A user data script"
  default     = "cd /tmp && echo \"Provisioned by Terraform\" > user_data.txt"
}

variable "private_ip" {}

variable "subnet_id" {}

variable "sg_ids" {
  type = "list"
  default = []
}

variable "sequence" {
  description = "Adds a sequence tag. An optional variable to allow for module dependence"
  default = "0"
}