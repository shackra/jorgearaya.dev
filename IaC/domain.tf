resource "digitalocean_domain" "default" {
  name       = "jorgearaya.dev"
  ip_address = digitalocean_droplet.website.ipv4_address
}

resource "digitalocean_domain" "esavara" {
  name       = "esavara.cr"
  ip_address = digitalocean_droplet.website.ipv4_address
}

resource "digitalocean_record" "nextcloud" {
  domain = digitalocean_domain.esavara.name
  type   = "A"
  name   = "nc"
  value  = digitalocean_droplet.website.ipv4_address
  ttl    = 3600
}

resource "digitalocean_record" "esavara_www" {
  domain = digitalocean_domain.esavara.name
  type   = "A"
  name   = "www"
  value  = digitalocean_droplet.website.ipv4_address
  ttl    = 3600
}

resource "digitalocean_record" "esavara_www_nc" {
  domain = digitalocean_domain.esavara.name
  type   = "A"
  name   = "www.nc"
  value  = digitalocean_droplet.website.ipv4_address
  ttl    = 3600
}

resource "digitalocean_record" "misc" {
  domain = digitalocean_domain.default.name
  type   = "A"
  name   = "misc"
  value  = digitalocean_droplet.website.ipv4_address
  ttl    = 3600
}

resource "digitalocean_record" "jardin" {
  domain = digitalocean_domain.default.name
  type   = "A"
  name   = "jardin"
  value  = digitalocean_droplet.website.ipv4_address
  ttl    = 3600
}

resource "digitalocean_record" "vpn" {
  domain = digitalocean_domain.default.name
  type   = "A"
  name   = "vpn"
  value  = digitalocean_droplet.vpn.ipv4_address
  ttl    = 3600
}

resource "digitalocean_record" "znc" {
  domain = digitalocean_domain.default.name
  type   = "A"
  name   = "znc"
  value  = digitalocean_droplet.znc.ipv4_address
  ttl    = 3600
}
