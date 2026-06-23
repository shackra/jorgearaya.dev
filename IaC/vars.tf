variable "sizes" {
  type        = map(string)
  description = "Recommended droplet sizes"
  default = {
    micro    = "s-1vcpu-512mb-10gb" # ~4 USD/mes
    small    = "s-1vcpu-1gb"        # ~6 USD/mes
    medium   = "s-1vcpu-2gb-amd"    # ~14 USD/mes
    medium_x = "s-2vcpu-2gb"        # ~18 USD/mes
  }
}
