output "droplets" {
  description = "Each droplet domain and age key"
  value = {
    website = {
      domain  = digitalocean_domain.default.id
      age_key = data.external.age_key["website"].result.age_key
    }
    nextcloud = {
      domain  = digitalocean_record.nextcloud.fqdn
      age_key = data.external.age_key["website"].result.age_key
    }
    vpn = {
      domain  = digitalocean_record.vpn.fqdn
      age_key = data.external.age_key["vpn"].result.age_key
    }
    znc = {
      domain  = digitalocean_record.znc.fqdn
      age_key = data.external.age_key["znc"].result.age_key
    }
  }
}
