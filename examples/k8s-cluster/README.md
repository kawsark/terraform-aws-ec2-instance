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
Run the `kubeadm init` example command on the Master node to initialize the cluster.
- Optionally add  `--apiserver-cert-extra-sans` parameter to a proper hostname for the K8S API server. E.g. `--apiserver-cert-extra-sans=k8s-api.example.org`
```
# Execute on master node
export ipv4=$(curl -s 169.254.169.254/latest/meta-data/local-ipv4)
sudo kubeadm init --apiserver-advertise-address ${ipv4} --pod-network-cidr=192.168.0.0/16

# Run the resulting command on other nodes
# Note: you commands will be different
_sudo kubeadm join --token c04797.8db60f6b2c0dd078 192.168.12.10:6443 --discovery-token-ca-cert-hash sha256:88ebb5d5f7fdfcbbc3cde98690b1dea9d0f96de4a7e6bf69198172debca74cd0_
```

### Installing CNI with Weave:
```
# Run on master node:

## Adjust kubectl
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

## Install CNI
export kubever=$(sudo kubectl version | base64 | tr -d '\n')
sudo kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$kubever"
sudo kubectl get nodes
```

### Validate setup
```
# On master node:
kubectl version
kubectl cluster-info
kubectl get pods -n kube-system
kubectl get events
```

### Enable Kubernetes Dashboard (Optional)
Following steps from [Schoolofdevops](https://github.com/schoolofdevops/kubernetes-fundamentals/blob/master/tutorials/1.%20install_kubernetes.md#enable-kubernetes-dashboard)

Installing Dashboard:
```
kubectl apply -f https://gist.githubusercontent.com/initcron/32ff89394c881414ea7ef7f4d3a1d499/raw/baffda78ffdcaf8ece87a76fb2bb3fd767820a3f/kube-dashboard.yaml
```
This will create a pod for the Kubernetes Dashboard. To access the Dashboard in the browser, run the below command:
```
kubectl describe svc kubernetes-dashboard -n kube-system
```

Now check for the NodePort and go to the browser: `https://masterip:NodePort`

