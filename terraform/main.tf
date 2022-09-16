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

resource "datadog_monitor" "http_monitor" {
  name    = "http_monitor"
  type    = "service check"
  message = "@all"

  query = "\"http.can_connect\".over(\"instance:http_health_check\").by(\"host\",\"instance\",\"url\").last(4).count_by_status()"

  monitor_thresholds {
    warning  = 1
    ok       = 1
    critical = 3
  }

  notify_no_data    = true
  no_data_timeframe = 2
  renotify_interval = 0
  new_group_delay   = 60

  notify_audit = false
  locked       = false

  timeout_h    = 60
  include_tags = true

  priority = 5

  tags = ["dev-project"]
}

output "web" {
  value = digitalocean_droplet.web.*
}
