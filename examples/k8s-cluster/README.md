### Terraform code to initialize a K8S cluster in AWS
https://github.com/schoolofdevops/kubernetes-fundamentals/blob/master/tutorials/1.%20install_kubernetes.md

### Adjust provider:

If `create_cloudflare_dns=1`, then the following Cloudflare provider variables will need be set:
```
export CLOUDFLARE_EMAIL=<cloudflare-email>
export CLOUDFLARE_TOKEN=<cloudflare-token>
```

### Adjust variables:
```
cp terraform.tfvars.example terraform.tfvars
# Set required variables: key_name, security_group_ingress and any other optional ones you want to set. For example:

vim terraform.tfvars
owner = "kawsar"
key_name = "your-useast2-keypair"
security_group_ingress = ["your-ip-address/32"]
aws_region = "us-east-2"
environment = "dev"
create_cloudflare_dns = "1"
cloudflare_domain = "example.com"
ttl = 120%
```

### Post Apply steps:
```
# On master node
export ipv4=$(curl -s 169.254.169.254/latest/meta-data/local-ipv4)
sudo kubeadm init --apiserver-advertise-address ${ipv4} --pod-network-cidr=192.168.0.0/16

# Run the resulting command on other nodes:
# Note: you commands will be different
_sudo kubeadm join --token c04797.8db60f6b2c0dd078 192.168.12.10:6443 --discovery-token-ca-cert-hash sha256:88ebb5d5f7fdfcbbc3cde98690b1dea9d0f96de4a7e6bf69198172debca74cd0_
```

### Installing CNI with Weave:
```
# Run on master node:
export kubever=$(sudo kubectl version | base64 | tr -d '\n')
sudo kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$kubever"
sudo kubectl get nodes
```

### Validate setup:
```
sudo kubectl version
sudo kubectl cluster-info
sudo kubectl get pods -n kube-system
sudo kubectl get events
```