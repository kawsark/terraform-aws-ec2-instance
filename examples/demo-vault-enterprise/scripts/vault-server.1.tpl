#!/bin/bash

# Set variables
export PATH="$${PATH}:/usr/local/bin"
export local_ip="$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)"
export VAULT_ADDR="http://$${local_ip}:8200"

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

# Write consul client configuration
cat <<EOF > /etc/consul.d/client.hcl
datacenter = "${dc}"
data_dir = "/opt/consul"
bind_addr = "$${local_ip}"
server = false
log_level = "DEBUG"
retry_join = ${retry_join}
EOF

echo "Starting consul client"
chown -R consul:consul /etc/consul.d
systemctl enable consul.service
systemctl daemon-reload
systemctl start consul.service
sleep 5
consul members

# Write vault server configuration:
export local_ip=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)
export public_ip=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)
cat <<EOF > /etc/vault.d/server.hcl
listener "tcp" {
  address = "$${local_ip}:8200"
  tls_disable = "true"
}

storage "consul" {
  address = "http://127.0.0.1:8500"
  path    = "${dc}-vault/"
}
log_level = "Trace"
ui = "true"
api_addr = "http://$${public_ip}:8200"
EOF

# Start vault daemon:
setcap cap_ipc_lock=+ep /usr/local/bin/vault

echo "Starting vault service"
chown -R vault:vault /etc/vault.d
systemctl enable vault.service
systemctl daemon-reload
systemctl start vault.service

# Wait for vault to register with consul
vault_consul_is_up

#Initialize and unseal Vault:
sleep 60
vault operator unseal $(consul kv get vault/unseal_key)
vault status

# Setup bash profile
cat <<EOF >> /home/ubuntu/.bashrc
export VAULT_ADDR="http://$${local_ip}:8200"
EOF