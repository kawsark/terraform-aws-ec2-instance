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

echo "Start Consul client n4"
cp consul-client.json /etc/consul.d
nohup consul agent -config-file=consul-client.json -bind "192.168.0.13" \
  > /tmp/consul-client-out.txt 2> /tmp/consul-client-err.txt &

echo "Start Nomad server n4"
sleep 30
chmod +x vault-addr.sh
source ./vault-addr.sh
export VAULT_TOKEN=$(consul kv get nomad/nomad_server_token)
vault token lookup
cp nomad-server.json /etc/nomad.d
nomad agent -config=/etc/nomad.d/nomad-server.json \
  > /tmp/nomad-server-out.txt 2> /tmp/nomad-server-err.txt &
