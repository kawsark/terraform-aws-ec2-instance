#!/bin/bash

function vault_consul_is_up {
  try=0
  max=12
  vault_consul_is_up=$(consul catalog services | grep vault)
  while [ -z "$vault_consul_is_up" ]
  do
    touch "/tmp/vault-try-$try"
    if [[ "$try" == '12' ]]; then
      echo "Giving up on consul catalog services after 12 attempts."
      break
    fi
    ((try++))
    echo "Vault or Consul is not up, sleeping 10 secs [$try/$max]"
    sleep 10
    vault_consul_is_up=$(consul catalog services | grep vault)
  done

  echo "Vault and Consul is up, proceeding with Initialization"
}

# Set path
export PATH=$PATH:/usr/local/bin

# Install Consul

# Install dependencies
sudo yum update
sudo yum install -y git unzip curl jq dnsutils dnsmasq

# Download and install consul
echo "Fetching Consul version ${CONSUL_VERSION} ..."
cd /tmp/
curl -s https://releases.hashicorp.com/consul/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_linux_amd64.zip -o consul.zip
unzip consul.zip
sudo mv consul /usr/local/bin/
consul --version

# Add consul user
sudo useradd --system --home /etc/consul.d --shell /bin/false consul
sudo mkdir --parents /opt/consul
sudo chown -R consul:consul /opt/consul
sudo chown consul:consul /usr/local/bin/consul

# Configure /etc/consul.d/consul.hcl
sudo mkdir --parents /etc/consul.d
sudo touch /etc/consul.d/consul.hcl
sudo chown --recursive consul:consul /etc/consul.d
sudo chmod 640 /etc/consul.d/consul.hcl

cat <<EOF > /etc/consul.d/consul.hcl
datacenter = "vault-dc1"
data_dir = "/opt/consul"
EOF
echo "encrypt = \"$(/usr/local/bin/consul keygen)\"" >> /etc/consul.d/consul.hcl

# Configure /etc/consul.d/server.hcl
sudo mkdir --parents /etc/consul.d
sudo touch /etc/consul.d/server.hcl
sudo chown --recursive consul:consul /etc/consul.d
sudo chmod 640 /etc/consul.d/server.hcl

cat <<EOF > /etc/consul.d/server.hcl
server = true
bootstrap_expect = 1
ui = true
EOF
echo "bind_addr = \"$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)\"" >> /etc/consul.d/server.hcl

# Start consul daemon:
# sudo -u consul nohup /usr/local/bin/consul agent -config-dir=/etc/consul.d/ &> /opt/consul/consul.out &
sudo mkdir -p /var/log/consul
sudo chown -R consul:consul /var/log/consul
sudo chmod -R u+rw /var/log/consul
sudo curl -s https://raw.githubusercontent.com/tonyp-hc/hashicorp-helper-scripts/master/consul/startup/consul.init -o /etc/init.d/consul
sudo chown root:root /etc/init.d/consul
sudo chmod u+x /etc/init.d/consul
service consul start

# Install Vault
curl -s https://releases.hashicorp.com/vault/${VAULT_VERSION}/vault_${VAULT_VERSION}_linux_amd64.zip -o vault.zip
unzip vault.zip
sudo mv vault /usr/local/bin/
vault --version

# Add vault user:
sudo useradd --system --home /etc/vault.d --shell /bin/false vault
sudo mkdir --parents /etc/vault.d
sudo touch /etc/vault.d/vault.hcl
sudo chown -R vault:vault /etc/vault.d
sudo chmod 640 /etc/vault.d/vault.hcl
sudo chown vault:vault /usr/local/bin/vault

# Add /etc/vault.d/vault.hcl file:
cat <<EOF > /etc/vault.d/vault.hcl
listener "tcp" {
  address = "0.0.0.0:8200"
  tls_disable = "true"
}
storage "consul" {
  address = "127.0.0.1:8500"
  path    = "vault/"
}
ui = "true"
EOF

# Create /opt/vault:
sudo mkdir -p /opt/vault
sudo chown -R vault:vault /opt/vault
sudo chmod -R u+rwx /opt/vault

# Start vault daemon:
sudo setcap cap_ipc_lock=+ep /usr/local/bin/vault
# sudo -u vault nohup /usr/local/bin/vault server -config=/etc/vault.d/vault.hcl &> /opt/vault/vault.out &
sudo mkdir -p /var/log/vault
sudo chown -R vault:vault /var/log/vault
sudo chmod -R u+rw /var/log/vault
sudo curl -s https://raw.githubusercontent.com/tonyp-hc/hashicorp-helper-scripts/master/vault/startup/vault.init -o /etc/init.d/vault
sudo chown root:root /etc/init.d/vault
sudo chmod u+x /etc/init.d/vault
service vault start

# Wait for vault to register with consul
vault_consul_is_up

# Initialize and unseal:
export VAULT_ADDR="http://localhost:8200"
vault operator init -format=json -n 1 -t 1 > /opt/vault/vault.txt
cat /opt/vault/vault.txt | jq -r '.unseal_keys_b64[0]' > /opt/vault/unseal_key
cat /opt/vault/vault.txt | jq -r .root_token > /opt/vault/root_token
export VAULT_TOKEN=$(cat /opt/vault/root_token)
vault operator unseal $(cat /opt/vault/unseal_key)
chown -R vault:vault /opt/vault

echo "Setup DNS"
cat <<EOF > /etc/dnsmasq.d/consul.dnsmasq
# Enable forward lookup of the 'consul' domain:
server=/consul/127.0.0.1#8600
EOF
cp /etc/resolv.conf /etc/resolv.conf.backup
echo "nameserver 127.0.0.1" | tee /etc/resolv.conf
cat /etc/resolv.conf.backup | tee --append /etc/resolv.conf
service dnsmasq restart

echo "export VAULT_ADDR=\"https://$(curl -s http://169.254.169.254/latest/meta-data/hostname):8200\"" >> /home/ec2-user/.bashrc
echo "export VAULT_TOKEN=$(cat /opt/vault/root_token)" >> /home/ec2-user/.bashrc
