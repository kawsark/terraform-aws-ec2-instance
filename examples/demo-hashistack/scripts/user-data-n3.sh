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

echo "Install Docker"
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
apt-get update -y
sudo apt-get install -y docker-ce
groupadd docker
usermod -aG docker ubuntu
systemctl enable docker
systemctl start docker

echo "Download redis client and build image"
mkdir -p /tmp/redis-client-service
git clone https://github.com/kawsark/redis-client-service.git -b password /tmp/redis-client-service
docker build -t python-clientms /tmp/redis-client-service

echo "Start Consul client n3"
cp consul-client.json /etc/consul.d
nohup consul agent -config-file=consul-client.json -bind "192.168.0.12" \
  > /tmp/consul-client-out.txt 2> /tmp/consul-client-err.txt &

echo "Start Nomad client n3"
sleep 40
cp nomad-client.json /etc/nomad.d
nomad agent -config=/etc/nomad.d/nomad-client.json \
  > /tmp/nomad-client-out.txt 2> /tmp/nomad-client-err.txt &
