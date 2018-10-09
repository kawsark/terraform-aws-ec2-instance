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

echo "Start Consul server n1"
cp consul-server.json /etc/consul.d
nohup consul agent -config-file=/etc/consul.d/consul-server.json \
 -bind "192.168.0.10" -retry-join "192.168.0.11" > \
  /tmp/consul-out.txt 2> /tmp/consul-err.txt &

echo "Start Vault server n1"
sleep 5
cp vault-n1.hcl /etc/vault.d
nohup vault server -config=/etc/vault.d/vault-n1.hcl -log-level=debug \
  > /tmp/vault-out.txt 2> /tmp/vault-err.txt &

sleep 5
sudo chmod +x vault-setup.sh
vault-setup.sh
