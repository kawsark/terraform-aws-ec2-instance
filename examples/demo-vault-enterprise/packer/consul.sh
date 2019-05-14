#!/bin/bash

# Set path
export PATH=$PATH:/usr/local/bin

# Install pre-reqs
echo "Installing dependencies ..."
apt-get update -y
apt-get install -y unzip curl dnsutils dnsmasq python

# Download consul
cd /tmp/
curl -s ${consul_url} -o consul.zip
unzip consul.zip
mv consul /usr/local/bin/consul
chmod +x /usr/local/bin/consul
consul --version

# Add consul user and make directories
echo "Creating consul user and directories"
mkdir -p /etc/consul.d
useradd --system --home /etc/consul.d --shell /bin/false consul
mkdir --parents /opt/consul
chown -R consul:consul /opt/consul
chown -R consul:consul /etc/consul.d
chown consul:consul /usr/local/bin/consul

# Install Consul Unit file
cat <<EOF > /etc/systemd/system/consul.service
[Unit]
Description=consul agent
Requires=network-online.target
After=network-online.target
[Service]
Restart=always
RestartSec=15s
User=consul
Group=consul
ExecStart=/usr/local/bin/consul agent -config-dir=/etc/consul.d
ExecReload=/bin/kill -HUP $MAINPID
KillSignal=SIGTERM
[Install]
WantedBy=multi-user.target
EOF

# Disable service - this will be overridden by Userdata script
systemctl disable consul.service

# Setup dnsmasq
cat <<EOF > /etc/dnsmasq.d/consul.dnsmasq
# Enable forward lookup of the 'consul' domain:
server=/consul/127.0.0.1#8600
EOF
cp /etc/resolv.conf /etc/resolv.conf.backup
echo "nameserver 127.0.0.1" | tee /etc/resolv.conf
cat /etc/resolv.conf.backup | tee --append /etc/resolv.conf
systemctl enable dnsmasq

# Reload services
systemctl daemon-reload