resource "digitalocean_record" "dmarc_jorge" {
  domain = digitalocean_domain.default.name
  type   = "TXT"
  name   = "_dmarc"
  value  = "v=DMARC1; p=quarantine"
  ttl    = 3600
}

resource "digitalocean_record" "spf_jorge" {
  domain = digitalocean_domain.default.name
  type   = "TXT"
  name   = "@"
  value  = "v=spf1 include:_spf.protonmail.ch ~all"
  ttl    = 3600
}

resource "digitalocean_record" "protonmail_verification_jorge" {
  domain = digitalocean_domain.default.name
  type   = "TXT"
  name   = "@"
  value  = "protonmail-verification=7e6e2924d12bbb818433ac9cb70763e2991269fb"
  ttl    = 3600
}

# DKIM (CNAMEs ProtonMail)
resource "digitalocean_record" "proton_dkim1" {
  domain = digitalocean_domain.default.name
  type   = "CNAME"
  name   = "protonmail._domainkey"
  value  = "protonmail.domainkey.d3p2nr5oozofc3euycztzzr6t2kn53cafvcity2vkagrunr2cbxaa.domains.proton.ch."
  ttl    = 43200
}

resource "digitalocean_record" "proton_dkim2" {
  domain = digitalocean_domain.default.name
  type   = "CNAME"
  name   = "protonmail2._domainkey"
  value  = "protonmail2.domainkey.d3p2nr5oozofc3euycztzzr6t2kn53cafvcity2vkagrunr2cbxaa.domains.proton.ch."
  ttl    = 43200
}

resource "digitalocean_record" "proton_dkim3" {
  domain = digitalocean_domain.default.name
  type   = "CNAME"
  name   = "protonmail3._domainkey"
  value  = "protonmail3.domainkey.d3p2nr5oozofc3euycztzzr6t2kn53cafvcity2vkagrunr2cbxaa.domains.proton.ch."
  ttl    = 43200
}

# MX Records (ProtonMail)
resource "digitalocean_record" "mx1_jorge" {
  domain   = digitalocean_domain.default.name
  type     = "MX"
  name     = "@"
  priority = 10
  value    = "mail.protonmail.ch."
  ttl      = 14400
}

resource "digitalocean_record" "mx2_jorge" {
  domain   = digitalocean_domain.default.name
  type     = "MX"
  name     = "@"
  priority = 20
  value    = "mailsec.protonmail.ch."
  ttl      = 14400
}
