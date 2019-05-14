## Demo Vault Enterprise cluster on AWS
**Important:** Please don't use this code for production as-is. You may review the code here and adopt it per [Vault Production hardening guidelines](https://learn.hashicorp.com/vault/operations/production-hardening)

This repository will provision a Vault and Consul cluster per reference architecture on AWS.

### Setup:
Create a `terraform.auto.tfvars` file will required variable values:
```
# Note: this is an example, your values will be different
cat <<EOF >terraform.auto.tfvars
aws_region="us-east-2"
vault_license="obtain-from-hashicorp"
consul_license="obtain-from-hashicorp"
owner="your-name"
key_name="aws-key"
security_group_ingress="$(curl http://whatismyip.akamai.com)/32"
EOF
```
Run terraform commands:
```
terraform init
terraform plan
terraform apply
```

