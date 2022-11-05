variable "aws_region" {
  description = "AWS region"
  default     = "us-east-2"
}

variable "subnet_id_public" {
  #TODO: Use terraform remote state for this
  description = "Public subnet id that EC2 instances should be launched in"
}

variable "subnet_id_private" {
  #TODO: Use terraform remote state for this
  description = "Public subnet id that EC2 instances should be launched in"
}

variable "security_group_ids" {
  #TODO: Use terraform remote state for this
  description = "The security groups that this EC2 instance should be attached to"
}

variable "go_sdk_version" {
  description = "Go SDK verson to install for userdata"
  default     = "go1.19.2"
}

variable "ssh_public_key" {
  description = "Optional public key to SSH into server (appended to /home/ubuntu/.ssh/authorized_keys)"
  default     = ""
}


variable "num_servers" {
  description = "How many servers to provision"
  default     = 1
}

variable "instance_type" {
  description = "type of EC2 instance to provision."
  default     = "t2.small"
}

variable "name" {
  description = "name to pass to Name tag"
  default     = "terraform-ubuntu"
}

variable "owner" {
  description = "An Owner tag"
  default     = "tfdemo"
}

variable "ttl" {
  description = "A desired time to live (not enforced via terraform)"
  default     = "48"
}

