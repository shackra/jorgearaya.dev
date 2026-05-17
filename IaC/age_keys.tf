locals {
  droplets = {
    website = digitalocean_droplet.website.ipv4_address
    vpn     = digitalocean_droplet.vpn.ipv4_address
    znc     = digitalocean_droplet.znc.ipv4_address
  }
}

data "external" "age_key" {
  for_each = local.droplets

  program = [
    "bash", "-c",
    <<-EOT
      key=$(ssh -i ~/.ssh/id_jorgearayadev -o StrictHostKeyChecking=accept-new -o ConnectTimeout=10 root@${each.value} \
        "nix-shell -p ssh-to-age --run 'cat /etc/ssh/ssh_host_ed25519_key.pub | ssh-to-age'" 2>/dev/null)
      echo "{\"age_key\": \"$key\"}"
    EOT
  ]
}
