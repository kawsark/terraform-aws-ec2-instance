listener "tcp" {
  address          = "0.0.0.0:8200"
  cluster_address  = "192.168.0.14:8201"
  tls_disable      = "true"
}

storage "consul" {
  address = "localhost:8500"
  path    = "vault/"
}

api_addr = "http://192.168.0.14:8200"
cluster_addr = "https://192.168.0.14:8201"
