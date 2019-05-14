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

chown -R vault:vault /etc/vault.d
systemctl enable vault.service
systemctl daemon-reload
systemctl start vault.service

# Wait for vault to register with consul
vault_consul_is_up

#Initialize and unseal Vault:
sleep 10
vault operator init -format=json -n 1 -t 1 > /opt/vault/vault.txt
cat /opt/vault/vault.txt | python -c 'import sys,json;print json.load(sys.stdin)["unseal_keys_b64"]' | cut -d\' -f2 > /opt/vault/unseal_key
cat /opt/vault/vault.txt | python -c 'import sys,json;print json.load(sys.stdin)["root_token"]' | cut -d\' -f2 > /opt/vault/root_token
vault operator unseal $(cat /opt/vault/unseal_key)
consul kv put vault/unseal_key $(cat /opt/vault/unseal_key)
vault status

# Proceed with additional vault configuration:
export VAULT_TOKEN=$(cat /opt/vault/root_token)
vault write sys/license text=${vault_license}
vault read -format=json sys/license > /opt/vault/license_status
echo "Vault license: $(vault read -format=json sys/license)"

# Setup bash profile
cat <<EOF >> /home/ubuntu/.bashrc
export VAULT_ADDR="http://$${local_ip}:8200"
export VAULT_TOKEN=$(cat /opt/vault/root_token)
EOF
