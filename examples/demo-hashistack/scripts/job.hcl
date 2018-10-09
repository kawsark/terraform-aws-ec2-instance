job "hashitemplate" {
  datacenters = ["local-dc1"]

  group "example" {
    task "server" {

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
  
      driver = "docker"

      config {
        image = "hashicorp/http-echo"
        args = [
          "-listen", ":5678",
          "-text", "hello world",
        ]
      }

      resources {
        network {
          mbits = 10
          port "http" {
            static = "5678"
          }
        }
      }
      
    }
  }
}
