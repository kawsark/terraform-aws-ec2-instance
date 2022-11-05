#!/bin/bash

# Install dependencies
echo "INFO: Installing dependencies ..."
sudo apt-get update -y
sudo apt-get install -y git unzip curl jq wget make awscli python3-pip
sudo pip3 install --upgrade awscli
sudo pip3 install git-remote-codecommit

# Install Kubectl
sudo snap install kubectl --classic
kubectl version --client

# Install EKSCTL
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
sudo mv /tmp/eksctl /usr/local/bin
eksctl version


# Add SSH key
echo "INFO: SSH public key sum: $(echo $SSH_KEY | md5sum)"
mkdir -p /home/ubuntu/.ssh && echo $SSH_KEY >> /home/ubuntu/.ssh/authorized_keys
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
git clone https://gitlab.com/kawsark/goshares.git
cd goshares
make build
make build_darwin
chown -R ubuntu:ubuntu /home/ubuntu/goshares

# Optional - install IDE
#apt-get install emacs -y
