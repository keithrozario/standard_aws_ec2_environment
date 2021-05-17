#  Every module which references a non-Hashicorp provider needs a required_providers 
#  block specifying the providers' source. The module needs to be upgraded to work
#  with terraform v0.13+.
#  https://github.com/hashicorp/terraform/issues/27701

terraform {
  required_providers {
    cloudflare = {
      source = "cloudflare/cloudflare"
      version = "~> 2.0"
    }
  }
}

variable cloudflare_api_token {}
provider "cloudflare" { 
  api_token = var.cloudflare_api_token
}