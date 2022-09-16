terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
    datadog = {
      source  = "DataDog/datadog"
      version = "3.4.0"
    }
  }
}

provider "digitalocean" {
  token = var.do_token
}

provider "datadog" {
  api_key = var.DD_API_KEY
  app_key = var.DD_APP_KEY
}
