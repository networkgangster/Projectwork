variable "exoscale_key" {
  description = "The Exoscale API key"
  type = string
}

variable "exoscale_secret" {
  description = "The Exoscale API secret"
  type = string
}

terraform {
  required_providers {
    exoscale = {
      source  = "terraform-providers/exoscale"
    }
  }
}

provider "exoscale" {
  version = "~> 0.15"
  key = var.exoscale_key
  secret = var.exoscale_secret
  compute_endpoint = "https://api.exoscale.com/compute"
}

resource "exoscale_ssh_keypair" "ssh_keypair"{
  name = "ssh_keypair"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDJN06fHUunAxkcDcNc0cRrWP3PB97LcgLEjIE4QxOA+ufX3ihM04sJUtjE4yluiKlZbUpR906ElmnsCG5/w+Ib1527xXkhgdwrdjY5MSVjIqKA/t5xpxcu7MrjXhQEIK5rl7AKtFmUdgOqXUkOVYErzhJWkfrfEceCt3RKmlaMg1CqmXUB6RVFjXdL1vErTecZgaXo+xyoxVVx9z/vOsoqd8SK/Jh8QnYfXBGabe+b8StGXyvQQZBnp/opqh3dEYNBFZgAZTc0mO/xbrFB9RbeN8eKLsLUAsQqcFYJNIQnOc5Kc22F+OaIbXpLNjqaXfQdwwMvygDig3zm+iqs43bB abdus@Qabdul"
}