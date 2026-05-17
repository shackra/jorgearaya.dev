resource "digitalocean_record" "dmarc" {
  domain = digitalocean_domain.esavara.name
  type   = "CNAME"
  name   = "_dmarc"
  value  = "_dmarc.esavara_cr._d.easydmarc.pro."
  ttl    = 43200
}

resource "digitalocean_record" "spf" {
  domain = digitalocean_domain.esavara.name
  type   = "TXT"
  name   = "@"
  value  = "v=spf1 include:_spf.esavara_cr._d.easydmarc.pro ~all"
  ttl    = 3600
}

resource "digitalocean_record" "protonmail_verification" {
  domain = digitalocean_domain.esavara.name
  type   = "TXT"
  name   = "@"
  value  = "protonmail-verification=792cf7c81900df8ba73a9e41df102178aa0707ff"
  ttl    = 3600
}

# DomainKeys (CNAMEs de ProtonMail)
resource "digitalocean_record" "protonmail_dkim1" {
  domain = digitalocean_domain.esavara.name
  type   = "CNAME"
  name   = "protonmail._domainkey"
  value  = "protonmail.domainkey.d7i5aakd6lt5dozglbjujipokvvitfedcfgobe7f536eb2xm73tqq.domains.proton.ch."
  ttl    = 43200
}

resource "digitalocean_record" "protonmail_dkim2" {
  domain = digitalocean_domain.esavara.name
  type   = "CNAME"
  name   = "protonmail2._domainkey"
  value  = "protonmail2.domainkey.d7i5aakd6lt5dozglbjujipokvvitfedcfgobe7f536eb2xm73tqq.domains.proton.ch."
  ttl    = 43200
}

resource "digitalocean_record" "protonmail_dkim3" {
  domain = digitalocean_domain.esavara.name
  type   = "CNAME"
  name   = "protonmail3._domainkey"
  value  = "protonmail3.domainkey.d7i5aakd6lt5dozglbjujipokvvitfedcfgobe7f536eb2xm73tqq.domains.proton.ch."
  ttl    = 43200
}

# MX records (ProtonMail)
resource "digitalocean_record" "mx1" {
  domain   = digitalocean_domain.esavara.name
  type     = "MX"
  name     = "@"
  priority = 10
  value    = "mail.protonmail.ch."
  ttl      = 14400
}

resource "digitalocean_record" "mx2" {
  domain   = digitalocean_domain.esavara.name
  type     = "MX"
  name     = "@"
  priority = 20
  value    = "mailsec.protonmail.ch."
  ttl      = 14400
}
