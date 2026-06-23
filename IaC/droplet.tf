resource "digitalocean_droplet" "website" {
  name        = "jorgearaya.dev"
  image       = data.digitalocean_image.default_nixos.id
  size        = var.sizes["medium"]
  resize_disk = true
  region      = "nyc1"
  tags        = ["nixos"]
  vpc_uuid    = digitalocean_vpc.default.id
  backups     = true
  backup_policy {  # because this droplet has Nextcloud installed
    plan = "daily" # increase the cost by ~30%
    hour = 8       # 2am Costa Rica time
  }
}

resource "digitalocean_droplet" "vpn" {
  name     = "wireguard"
  image    = data.digitalocean_image.default_nixos.id
  size     = var.sizes["medium"]
  region   = "nyc1"
  tags     = ["nixos"]
  vpc_uuid = digitalocean_vpc.default.id
  ssh_keys = [data.digitalocean_ssh_key.default.fingerprint]
}

resource "digitalocean_droplet" "znc" {
  name     = "irc-bouncer"
  image    = data.digitalocean_image.default_nixos.id
  size     = var.sizes["micro"]
  region   = "nyc1"
  tags     = ["nixos"]
  vpc_uuid = digitalocean_vpc.default.id
  ssh_keys = [data.digitalocean_ssh_key.default.fingerprint]
}
