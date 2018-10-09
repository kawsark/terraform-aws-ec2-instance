#!/bin/bash
echo "Setup pre-req"
apt-get update -y
apt-get install -y curl unzip jq dnsutils dnsmasq git
cd /tmp
export git_branch="userdata"
export git_clone_url="https://github.com/kawsark/terraform-aws-ec2-instance.git"
export working_dir="terraform-aws-ec2-instance/examples/demo-hashistack/scripts"
git clone -b ${git_branch} --single-branch ${git_clone_url}
cd ${working_dir}
chmod +x base-hashistack.sh
./base-hashistack.sh

echo "Start Consul client n6"
cp consul-client.json /etc/consul.d
nohup consul agent -config-file=consul-client.json -bind "192.168.0.15" \
  > /tmp/consul-client-out.txt 2> /tmp/consul-client-err.txt &

echo "Start Vault server n6"
sleep 30
cp vault-n2.hcl /etc/vault.d
vault server -config=/etc/vault.d/vault-n6.hcl -log-level=debug \
  > /tmp/vault-out.txt 2> /tmp/vault-err.txt &

sleep 5
export VAULT_ADDR="http://localhost:8200"
export VAULT_TOKEN=$(consul kv get vault/root_token)
vault operator unseal $(consul kv get vault/unseal_key)
