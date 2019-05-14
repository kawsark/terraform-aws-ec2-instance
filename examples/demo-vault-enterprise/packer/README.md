## packer-build
The packer files in this directory can be used to build base Ubuntu OS images with Vault and Consul enterprise binary. Note that these images will not place the any configuration files in `/etc/consul.d` or `/etc/vault.d`. It is up to server initialization scripts to install those.

### Packer build steps:
- Download packer binary and ensure it is available in your path:
  - [Download page](https://www.packer.io/downloads.html)
  - [Install the binary](https://www.packer.io/intro/getting-started/install.html#precompiled-binaries)

- Modify [aws-env-example.sh](aws-env-example.sh) with appropriate environment variables.
- Source it and execute packer:
```
source aws-env-example.sh
packer build vault-base.json
packer build consul-base.json
```
