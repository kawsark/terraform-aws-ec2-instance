#!/bin/bash

#Initialize and unseal Vault:
export VAULT_ADDR="http://localhost:8200"
vault operator init -format=json -n 1 -t 1 > /tmp/vault.txt
cat /tmp/vault.txt | jq -r '.unseal_keys_b64[0]' > /tmp/unseal_key
cat /tmp/vault.txt | jq -r .root_token > /tmp/root_token
export VAULT_TOKEN=$(cat /tmp/root_token)

vault operator unseal $(cat /tmp/unseal_key)

consul kv put vault/root_token ${VAULT_TOKEN}
consul kv put vault/unseal_key $(cat /tmp/unseal_key)

# Vault setup for Nomad:
# Download Policy and Role
curl https://nomadproject.io/data/vault/nomad-server-policy.hcl -O -s -L
#Using customized role with allowed_policies parameter:
#curl https://nomadproject.io/data/vault/nomad-cluster-role.json -O -s -L

# Write the policy to Vault
vault policy write nomad-server nomad-server-policy.hcl

# Create the token role with Vault
vault write /auth/token/roles/nomad-cluster @nomad-cluster-role.json

# Retrieve the token based role:
vault token create -policy nomad-server -period 72h -orphan -format=json | jq -r .auth.client_token > /tmp/nomad_server_token
consul kv put nomad/nomad_server_token $(cat /tmp/nomad_server_token)

# Add general policy
vault policy write app-policy app-policy.hcl

# Write a secret
vault kv put secret/foo bar=baz
