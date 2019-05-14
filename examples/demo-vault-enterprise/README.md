## Demo Vault Enterprise cluster on AWS
**Important:** Please don't use this code for production. Please ensure you are carefully implementing [Vault Production hardening guidelines](https://learn.hashicorp.com/vault/operations/production-hardening) in your environment.

This repository will provision a Vault and Consul cluster per reference architecture on AWS.
- 2 Node Vault Enterprise cluster (Active / Standby)
- 3 Node Consul Enterprise cluster

### Setup:
- First create the necessary packer images using from [packer/](packer/) directory.
- Create a `terraform.auto.tfvars` file will required variable values:
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
- Run terraform commands:
```
terraform init
terraform plan
terraform apply
```

### Production recommendations:
Below are the recommendations from [Vault Production hardening guidelines](https://learn.hashicorp.com/vault/operations/production-hardening). This repo attempts to implement most of them.

- End-to-End TLS: _Pending implementation_.
- Single Tenancy: Yes - Vault is the main service running on EC2.
- Firewall traffic: Yes - Implemented AWS Security Groups 
- Disable SSH / Remote Desktop: _Pending implementation_.
- Disable Swap: _Pending implementation_.
- Don't Run as Root: Yes - Vault runs as the user `vault`.
- Turn Off Core Dumps: _Pending implementation_.
- Immutable Upgrades: Yes - Using packer based deployment.
- Avoid Root Tokens: Up to Administrator.
- Enable Auditing: _Pending implementation_.
- Upgrade Frequently: Yes.
- Configure SELinux / AppArmor: _Pending implementation_.
- Restrict Storage Access: Yes.
- Disable Shell Command History: _Pending implementation_.
- Tweak ulimits: _Pending implementation_.
- Docker Containers: N/A - this is a VM based deployment.

