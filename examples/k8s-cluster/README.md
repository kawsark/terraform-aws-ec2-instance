### Terraform code to initialize a K8S cluster in AWS
https://github.com/schoolofdevops/kubernetes-fundamentals/blob/master/tutorials/1.%20install_kubernetes.md

### Post Apply steps:
```
# On master node
export ipv4=$(curl -s 169.254.169.254/latest/meta-data/local-ipv4)
sudo kubeadm init --apiserver-advertise-address ${ipv4} --pod-network-cidr=192.168.0.0/16

# Run the resulting command on other nodes:
# Note: you commands will be different
_sudo kubeadm join --token c04797.8db60f6b2c0dd078 192.168.12.10:6443 --discovery-token-ca-cert-hash sha256:88ebb5d5f7fdfcbbc3cde98690b1dea9d0f96de4a7e6bf69198172debca74cd0_
```