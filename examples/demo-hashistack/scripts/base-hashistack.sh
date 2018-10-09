#!/bin/bash
export CONSUL_VERSION="1.2.2"
export VAULT_VERSION="0.10.4"
export NOMAD_VERSION="0.8.6"

echo "Installing Consul ..."
echo "Fetching Consul version ${CONSUL_VERSION} ..."
curl -s https://releases.hashicorp.com/consul/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_linux_amd64.zip -o consul.zip
echo "Installing Consul version ${CONSUL_VERSION} ..."
unzip consul.zip
mv consul /usr/bin/consul
chmod +x /usr/bin/consul
mkdir /etc/consul.d
chmod a+w /etc/consul.d

echo "Installing Vault ..."
echo "Fetching Vault version ${VAULT_VERSION} ..."
curl -s https://releases.hashicorp.com/vault/${VAULT_VERSION}/vault_${VAULT_VERSION}_linux_amd64.zip -o vault.zip
unzip vault.zip
mv vault /usr/bin/vault
chmod +x /usr/bin/vault
mkdir /etc/vault.d
chmod a+w /etc/vault.d

echo "Installing Nomad ..."
echo "Fetching Nomad version ${NOMAD_VERSION} ..."
curl -s https://releases.hashicorp.com/nomad/${NOMAD_VERSION}/nomad_${NOMAD_VERSION}_linux_amd64.zip -o nomad.zip
echo "Installing Nomad version ${NOMAD_VERSION} ..."
unzip nomad.zip
mv nomad /usr/bin/nomad
chmod +x /usr/bin/nomad
mkdir /etc/nomad.d
chmod a+w /etc/nomad.d

echo "Setup DNS"
cat hosts >> /etc/hosts
cp consul.dnsmasq /etc/dnsmasq.d
cp /etc/resolv.conf /etc/resolv.conf.backup
echo "nameserver 127.0.0.1" | tee /etc/resolv.conf
cat /etc/resolv.conf.backup | tee --append /etc/resolv.conf
systemctl restart dnsmasq
cp vault-addr.sh /etc/profile.d
chmod a+x /etc/profile.d/vault-addr.sh

echo "Set permissions"
chown -R ubuntu /tmp
