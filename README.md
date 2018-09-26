# Provision an EC2 instance in AWS
This Terraform configuration provisions an EC2 instance in AWS using CircleCI.

## Details
By default, this configuration provisions a Ubuntu 14.04 Base Image AMI (with ID ami-2e1ef954) with type t2.micro in the us-east-1 region. The AMI ID, region, and type can all be set as variables. You can also set the name variable to determine the value set for the Name tag.

### Building in CircleCI
1. Edit the [backend.tf](backend.tf) file to point to a valid S3 state store.
2. Set CircleCI Project Environment variables AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY. The values should contain valid AWS IAM credentials with access to S3 bucket specified in [backend.tf](backend.tf), and access to provision an EC2 instance in the specified region.
3. Set a owner tag as a CircleCI Project Environment: TF_VAR_owner. The value can be any string (email, name etc.)

### Destroying:
- Currently the [.circleci/config.yml](.circleci/config.yml) file does not contain `terraform destroy` instructions. Hence a destroy must be triggered locally as below:
```
export AWS_ACCESS_KEY_ID=your-access-key-id
export AWS_SECRET_ACCESS_KEY=your-access-key-id
terraform destroy
```
