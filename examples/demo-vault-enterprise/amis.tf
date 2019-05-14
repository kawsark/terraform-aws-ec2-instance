data "aws_ami" "vault" {
    most_recent = true
    owners      = ["753646501470"] # hc-sc-demos-2018

    filter {
        name   = "name"
        values = ["demo-vault-ent-base-ubuntu1604"]
    }
}

data "aws_ami" "consul" {
    most_recent = true
    owners      = ["753646501470"] # hc-sc-demos-2018

    filter {
        name   = "name"
        values = ["demo-consul-ent-base-ubuntu1604"]
    }
}