resource "digitalocean_droplet" "web" {
  count              = 2
  image              = "docker-20-04"
  name               = "web-${count.index + 1}"
  region             = "ams3"
  size               = "s-1vcpu-1gb"
  ssh_keys = [data.digitalocean_ssh_key.ssh_key_1.id]
}

resource "digitalocean_loadbalancer" "loadbalancer_1" {
  name   = "security-loadbalancer-example"
  region = "ams3"

  sticky_sessions {
    type               = "cookies"
    cookie_name        = "lb"
    cookie_ttl_seconds = 120
  }

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
    certificate_name = digitalocean_certificate.cert.name
  }

  healthcheck {
    port     = 3000
    protocol = "http"
    path     = "/"
  }

  redirect_http_to_https           = true
  disable_lets_encrypt_dns_records = true
  droplet_ids = digitalocean_droplet.web.*.id
}

resource "digitalocean_domain" "domain-1" {
  name = "project77.home-cooking.ru"
  ip_address = digitalocean_loadbalancer.loadbalancer_1.ip
}

resource "digitalocean_certificate" "cert" {
  name    = "certificate-domain"
  type    = "lets_encrypt"
  domains = [digitalocean_domain.domain-1.name]
}

data "digitalocean_ssh_key" "ssh_key_1" {
  name = "do-2022"
}
