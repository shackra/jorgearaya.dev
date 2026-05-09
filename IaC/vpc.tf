resource "digitalocean_vpc" "default" {
  name     = "default-vpc"
  region   = "nyc1"
  ip_range = "10.116.0.0/20"
}
