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

#Install Consul and dependencies
echo "Installing dependencies ..."
sudo apt-get update
sudo apt-get install -y git unzip curl jq dnsutils dnsmasq
echo "Fetching Consul version ${CONSUL_VERSION} ..."
cd /tmp/
curl -s https://releases.hashicorp.com/consul/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_linux_amd64.zip -o consul.zip
echo "Installing Consul version ${CONSUL_VERSION} ..."
unzip consul.zip
sudo chmod +x consul
sudo mv consul /usr/bin/consul
sudo mkdir /etc/consul.d
sudo chmod a+w /etc/consul.d

# Make directories for Vault and Consul
sudo mkdir /opt/consul
sudo mkdir /opt/vault
chown -R ubuntu /opt/consul
chown -R ubuntu /opt/vault
sudo chmod o+rwx /opt/consul
sudo chmod o+rxw /opt/vault

# Install and start Consul service
sudo cat <<EOF > /etc/systemd/system/consul.service
[Unit]
Description=consul agent
Requires=network-online.target
After=network-online.target
[Service]
Restart=always
RestartSec=15s
User=ubuntu
Group=ubuntu
ExecStart=/usr/bin/consul agent -config-dir=/etc/consul.d
ExecReload=/bin/kill -HUP $MAINPID
KillSignal=SIGTERM
[Install]
WantedBy=multi-user.target
EOF

sudo cat <<EOF > /etc/consul.d/consul.json
{
  "datacenter": "dc1",
  "data_dir": "/opt/consul",
  "log_level": "DEBUG",
  "node_name": "n1",
  "server": true,
  "bootstrap_expect": 1,
  "enable_script_checks": false,
  "bind_addr": "0.0.0.0",
  "client_addr": "0.0.0.0",
  "connect": {
    "enabled": true
  },
  "ui": true
}
EOF


# Start service
systemctl enable consul.service
systemctl start consul.service

# Install Vault
curl -s https://releases.hashicorp.com/vault/${VAULT_VERSION}/vault_${VAULT_VERSION}_linux_amd64.zip -o vault.zip
unzip vault.zip
sudo chmod +x vault
mv vault /usr/local/bin/vault
mkdir /etc/vault.d
chmod a+w /etc/vault.d

# Install Vault service:
cat <<EOF > /etc/systemd/system/vault.service
[Unit]
Description=Vault Agent
Requires=consul.service
After=consul.service

[Service]
Restart=on-failure
PermissionsStartOnly=true
ExecStartPre=/sbin/setcap 'cap_ipc_lock=+ep' /usr/local/bin/vault
ExecStart=/usr/local/bin/vault server -config /etc/vault.d -log-level=debug
ExecReload=/bin/kill -HUP $MAINPID
KillSignal=SIGTERM
User=ubuntu
Group=ubuntu
LimitMEMLOCK=infinity

[Install]
WantedBy=multi-user.target
EOF

# Write Vault configuration file:
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

# Start service
systemctl enable vault.service
systemctl start vault.service

# Wait for vault to register with consul
vault_consul_is_up

# Initialize and unseal:
export VAULT_ADDR="http://localhost:8200"
vault operator init -format=json -n 1 -t 1 > /opt/vault/vault.txt
cat /opt/vault/vault.txt | jq -r '.unseal_keys_b64[0]' > /opt/vault/unseal_key
cat /opt/vault/vault.txt | jq -r .root_token > /opt/vault/root_token
export VAULT_TOKEN=$(cat /opt/vault/root_token)
vault operator unseal $(cat /opt/vault/unseal_key)
consul kv put vault/root_token $(cat /opt/vault/root_token)

echo "Set permissions"
chown -R ubuntu /opt/vault

echo "Setup DNS"
cat <<EOF > /etc/dnsmasq.d/consul.dnsmasq
# Enable forward lookup of the 'consul' domain:
server=/consul/127.0.0.1#8600
EOF
cp /etc/resolv.conf /etc/resolv.conf.backup
echo "nameserver 127.0.0.1" | tee /etc/resolv.conf
cat /etc/resolv.conf.backup | tee --append /etc/resolv.conf
systemctl restart dnsmasq

echo 'export VAULT_ADDR="http://active.vault.service.consul:8200"' >> /home/ubuntu/.bashrc
echo "export VAULT_TOKEN=$(cat /opt/vault/root_token)" >> /home/ubuntu/.bashrc
