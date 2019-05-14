#!/bin/bash

# Set variables
export PATH="$${PATH}:/usr/local/bin"
export local_ip="$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)"
export CONSUL_HTTP_ADDR="http://127.0.0.1:8500"

cat <<EOF > /etc/consul.d/server.hcl
datacenter = "${dc}"
data_dir = "/opt/consul"
bind_addr = "$${local_ip}"
bootstrap_expect = ${consul_server_count}
server = true
ui = true
log_level = "trace"
retry_join = ${retry_join}
EOF

echo "Starting consul service"
chown -R consul:consul /etc/consul.d
systemctl enable consul.service
systemctl daemon-reload
systemctl start consul.service

# Apply Enterprise license after 10 minutes
sleep 300
consul members
consul license put ${consul_license}
consul license get > /opt/consul/license_status
echo "Consul license status: $(consul license get)"
