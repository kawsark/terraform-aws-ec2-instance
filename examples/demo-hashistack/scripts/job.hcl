vault {
      policies = ["app-policy"]
    }

template {
      data = <<EOH
      bar = {{ with secret "secret/foo" }}{{ .Data.bar }}{{end}}
      EOH

      destination = "secrets/config.env"
      env = true
}
