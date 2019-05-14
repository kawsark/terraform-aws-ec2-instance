#!/bin/bash

# Set path
export PATH=$PATH:/usr/local/bin

# Install pre-reqs
echo "Installing dependencies ..."
apt-get update -y
apt-get install -y unzip curl python

# Download vault
cd /tmp/
curl -s ${vault_url} -o vault.zip
unzip vault.zip
mv vault /usr/local/bin/vault
chmod +x /usr/local/bin/vault
vault --version

# Add vault user and make directories
echo "Creating vault user and directories"
mkdir -p /etc/vault.d
useradd --system --home /etc/vault.d --shell /bin/false vault
mkdir --parents /opt/vault
chown -R vault:vault /opt/vault
chown -R vault:vault /etc/vault.d
chown vault:vault /usr/local/bin/vault

# Install vault Unit file
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
User=vault
Group=vault
LimitMEMLOCK=infinity

[Install]
WantedBy=multi-user.target
EOF

# Disable service - this will be overridden by Userdata script
systemctl disable vault.service

# Reload services
systemctl daemon-reload