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