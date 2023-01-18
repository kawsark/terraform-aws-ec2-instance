#!/bin/bash

# Install dependencies
echo "INFO: Installing dependencies ..."
sudo apt-get update -y
sudo apt-get install -y git unzip curl jq wget make python3-pip nfs-common apache2-utils
#sudp apt-get install awscli 
#sudo pip3 install --upgrade awscli
sudo pip3 install git-remote-codecommit

# Install EFS client for EC2 and upgrade stunnel
sudo apt-get -y install git binutils
git clone https://github.com/aws/efs-utils
cd efs-utils
./build-deb.sh
sudo apt-get -y install ./build/amazon-efs-utils*deb
apt-get install stunnel4 -y

curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# Install Kubectl
sudo snap install kubectl --classic
kubectl version --client

# Install EKSCTL
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
sudo mv /tmp/eksctl /usr/local/bin
eksctl version

# Install helm
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh

# Add SSH key
echo "INFO: SSH public key word count: $(echo ${SSH_KEY} | wc)"
mkdir -p /home/ubuntu/.ssh && echo ${SSH_KEY} >> /home/ubuntu/.ssh/authorized_keys
echo "INFO: $(wc /home/ubuntu/.ssh/authorized_keys)"

# Install GO SDK
echo "INFO: Installing Go"
cd /tmp
wget -O ${GO_VERSION}.linux-amd64.tar.gz https://go.dev/dl/${GO_VERSION}.linux-amd64.tar.gz
rm -rf /usr/local/go && tar -C /usr/local -xzf ${GO_VERSION}.linux-amd64.tar.gz
echo 'export PATH=$PATH:/usr/local/go/bin' >> /home/ubuntu/.bashrc
export PATH=$PATH:/usr/local/go/bin

# Install Docker
# https://docs.docker.com/engine/install/ubuntu/
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo groupadd docker
sudo usermod -aG docker $USER

# Install terraform
# https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli
sudo apt-get update && sudo apt-get install -y gnupg software-properties-common
wget -O- https://apt.releases.hashicorp.com/gpg | \
    gpg --dearmor | \
    sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
    https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
    sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update -y
sudo apt-get install terraform -y

# Install Goshares app
echo "INFO: Installing Goshares app"
cd /home/ubuntu
mkdir -p go/src && cd go/src
git clone https://gitlab.com/kawsark/goshares.git
sudo chown -R ubuntu:ubuntu /home/ubuntu/go
cd goshares
export GOPATH=/home/ubuntu/go
make build
make build_darwin

# Optional - install IDE
#apt-get install emacs -y
