resource "digitalocean_droplet" "web" {
  count              = 2
  image              = "docker-20-04"
  name               = "web-${count.index + 1}"
  region             = "ams3"
  size               = "s-1vcpu-1gb"
  ssh_keys = [data.digitalocean_ssh_key.ssh_key_1.id]
}

resource "digitalocean_record" "record-1" {
  domain = digitalocean_domain.domain-1.name
  type   = "A"
  name   = "@"
  value  = digitalocean_loadbalancer.loadbalancer-1.ip
}

resource "digitalocean_domain" "domain-1" {
  name = "project77.home-cooking.ru"
}

resource "digitalocean_certificate" "certificate-1" {
  name    = "certificate-1"
  type    = "lets_encrypt"
  domains = [digitalocean_domain.domain-1.name]
}

data "digitalocean_ssh_key" "ssh_key_1" {
  name = "do-2022"
}

resource "digitalocean_loadbalancer" "loadbalancer-1" {
  name   = "loadbalancer"
  region = "ams3"

  forwarding_rule {
    entry_protocol  = "http"
    entry_port      = 80
    target_protocol = "http"
    target_port     = 3000
  }

  forwarding_rule {
    entry_protocol   = "https"
    entry_port       = 443
    target_protocol  = "http"
    target_port      = 3000
    certificate_name = digitalocean_certificate.certificate-1.name
  }

  healthcheck {
    port     = 3000
    protocol = "http"
    path     = "/"
  }

  droplet_ids = digitalocean_droplet.web.*.id
}
