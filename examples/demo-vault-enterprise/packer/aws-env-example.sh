#Setup Azure service credentials.
# Its recommended to source these from a File
#export AWS_ACCESS_KEY_ID=<access_key>
#export AWS_SECRET_ACCESS_KEY=<secret_key>

#Setup variables:
export location="us-east-2"
export vault_image_name=demo-vault-ent-base-ubuntu1604
export consul_image_name=demo-consul-ent-base-ubuntu1604
export vault_url="<obtain-ent-url-from-hashicorp>"
export consul_url="<obtain-ent-url-from-hashicorp>"
export consul_version="1.5.0"
export vault_version="1.1.2"

# Setup tags for Packer image:
export environment_tag="demo"
export owner_tag="kawsar@hashicorp.com"
