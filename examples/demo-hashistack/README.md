## Walkthru for using Vault PKI Secrets Engine to enable Consul RPC encryption with TLS.

### Setup:
Note: `jq` must be installed.

- Copy your your Vault Root Token and paste into `VAULT_TOKEN` variable.
- Export `VAULT_ADDR` and make temp working directory.
```
export ROOT_TOKEN=$(pbpaste)
export VAULT_TOKEN=${ROOT_TOKEN}
export VAULT_ADDR=http://127.0.0.1:8200
mkdir -p /tmp/certs/
```
- Set Root and Intermediate CA names.
- Set CA and Certificate TTLs (1 year / 1 week set below)
```
export RootCAName="consul-ca-root"
export InterimCAName="consul-ca-intermediate"
export CommonName="service.consul"
export CA_ttl="8765h"
export Cert_ttl="168h"
```

### Mount Root CA and generate certs:
- Delete any pre-existing secrets engine and mount Root CA at specified path:
- Tune the default lease time.
```
vault secrets disable ${RootCAName}
vault secrets enable -path ${RootCAName} pki
vault secrets tune -max-lease-ttl=${CA_ttl} ${RootCAName}
```
- Create the root CA certificates. Note the certificate and issuing_ca will be identical this this is a self-signed Root CA.
```
vault write -format=json ${RootCAName}/root/generate/internal \
common_name="${CommonName}" ttl=${CA_ttl} | tee \
>(jq -r .data.certificate > /tmp/certs/ca.pem) \
>(jq -r .data.issuing_ca > /tmp/certs/issuing_ca.pem)
```

### Mount Intermediate CA and generate CSR:
- Delete any pre-existing secrets engine and mount Root CA at specified path:
- Tune the default lease time for intermediate cert
```
vault secrets disable ${InterimCAName}
vault secrets enable -path ${InterimCAName} pki
vault secrets tune -max-lease-ttl=${CA_ttl} ${InterimCAName}
```
- Generate the Certificate Signing Request (CSR):
```
vault write -format=json ${InterimCAName}/intermediate/generate/internal \
common_name="${InterimCAName}" ttl=${CA_ttl} | tee \
>(jq -r .data.csr > /tmp/certs/${InterimCAName}.csr)
```
- Sign the intermediate Cert. We will end up with a Interim CA certificate and the issuing_ca certificate encoded in .pem format.
```
vault write -format=json ${RootCAName}/root/sign-intermediate \
csr=@/tmp/certs/${InterimCAName}.csr \
common_name="${CommonName}" ttl=${CA_ttl} | tee \
>(jq -r .data.certificate > /tmp/certs/${InterimCAName}.pem) \
>(jq -r .data.issuing_ca > /tmp/certs/${InterimCAName}_issuing_ca.pem)
```

- Set the intermediate Cert:
```
vault write ${InterimCAName}/intermediate/set-signed certificate=@/tmp/certs/${InterimCAName}.pem
```

- Set location of Certificate Revocation List and the location of the issuing certificate:
```
vault write ${InterimCAName}/config/urls \
issuing_certificates="http://127.0.0.1:8200/v1/${InterimCAName}/ca" \
crl_distribution_points="http://127.0.0.1:8200/v1/${InterimCAName}/crl"
```

### Generate certificate for `dev.service.consul` domain:
- Create a role for the `dev.service.consul` domain (note the short TTL):
- This role is allowed to create certificates with SANs in `dev.service.consul` and below, with a maximum certificate lifetime of ${Cert_ttl}.
- These certificates have an associated Vault lease, allowing them to be revoked either by certificate serial number or by the Vault lease.
```
vault write ${InterimCAName}/roles/service-dot-consul \
    allowed_domains="dev.${CommonName}" \
    allow_subdomains="true" \
    max_ttl=${Cert_ttl} \
    generate_lease=true
```

- Generate credentials (certificates):
```
vault write -format=json ${InterimCAName}/issue/service-dot-consul \
    common_name=app1.dev.${CommonName} |  tee \
>(jq -r .data.private_key > "/tmp/certs/app1.dev.${CommonName}-myprivatekey.pem") \
>(jq -r .data.certificate > "/tmp/certs/app1.dev.${CommonName}-certificate.pem")
```
- Create a Policy to allow a Demo user to issue certs:
```
cat <<EOF > /tmp/certs/cert.policy
path "${InterimCAName}/issue*" {
  capabilities = ["create","update"]
}
path "auth/token/renew" {
  capabilities = ["update"]
}
path "auth/token/renew-self" {
  capabilities = ["update"]
}
EOF
```
- Write the policy to vault:
```
vault policy write cert-policy /tmp/certs/cert.policy
```

- Mount userpass authentication backend and create a demo user with `cert-policy` mapped:
```
vault auth enable userpass
vault write auth/userpass/users/demo password=test policies=cert-policy
```

- unset the ROOT TOKEN and login using userpass method:
```
unset VAULT_TOKEN
vault login -method=userpass username=demo password=test
```

### Issue certs for demo user:
- The following command will issue certificate, private key (exported) and the Issuing CA information:
```
vault write -format=json ${InterimCAName}/issue/service-dot-consul \
    common_name=app1.dev.${CommonName} |  tee \
>(jq -r .data.private_key > /tmp/certs/app1.dev.${CommonName}-demo-myprivatekey.pem) \
>(jq -r .data.certificate > /tmp/certs/app1.dev.${CommonName}-demo-certificate.pem)
```

### Try to issue cert with an invalid domain name:
- Try to create a certificate which violates the domain name restriction. The `service-dot-consul` role only allows issuing of certificates under the `dev.service.consul` domain:
```
vault write -format=json ${InterimCAName}/issue/service-dot-consul \
    common_name=app1.prod.${CommonName}
```

- And one which tries to violate the lifetime restriction. Although a 1000 hour lifetime was requested, the role TTL limit of 8 hours was applied:
```
vault write -format=json ${InterimCAName}/issue/service-dot-consul \
    common_name=app1.dev.${CommonName} ttl=1000h
```

### Revoking certificates:
- Let’s say a the key of the first app certificate we issued was accidentally written to the application logging system.
- Revocation of the certificate is simple using the `/revoke` endpoint
```
vault write ${InterimCAName}/revoke \
  serial_number="<>"
```
- Revoking a certificate causes an update to the vault CRL, which can be exported to the CRL distribution point:
```
vault read ${InterimCAName}/cert/crl
```

### Examining the CRL (pending):
- Access CRL URL:
```
vault read ${InterimCAName}/config/urls
```

---------------------
### Consul Template:
- Obtain a new token and write consul template file:
```
export DEMO_TOKEN=$(vault login -format=json -method=userpass username=demo | jq -r .auth.client_token)

cat <<TPL > dynamic-cert.tpl
#{{ with secret "${InterimCAName}/issue/service-dot-consul" "common_name=nginx.dev.${CommonName}" }}
#{{ .Data.certificate }}
#{{ .Data.private_key }}
#{{ end }}
TPL

cat dynamic-cert.tpl

consul-template -template "dynamic-cert.tpl:app-certs.txt" \
 -vault-token=$DEMO_TOKEN -once

cat app-certs.txt
```

---------------------

### Revoke Issuing Permission
- Login as Root
```
export VAULT_TOKEN=$ROOT_TOKEN
```
- Create policy file and write to vault:
```
echo '
path "auth/token/renew" {
  capabilities = ["update"]
}
path "auth/token/renew-self" {
  capabilities = ["update"]
}' > /tmp/cert.auth.policy  
vault policy write cert-policy /tmp/cert.auth.policy
```

- unset ROOT TOKEN and login as demo user:
```
unset VAULT_TOKEN
vault login -method=userpass username=demo password=test
```
- You Are now denied the ability issue certs
```
vault write -format=json ${InterimCAName}/issue/service-dot-consul \
    common_name=app1.dev.${CommonName}
```

### Cleanup:
- Revoke demo user:
- Delete user and disable secret engines:
```
export VAULT_TOKEN=$ROOT_TOKEN
vault lease revoke -prefix auth/userpass/login/demo
vault delete auth/userpass/users/demo
vault secrets disable ${RootCAName}  
vault secrets disable ${InterimCAName}  
```
