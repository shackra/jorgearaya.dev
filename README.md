# jorgearaya.dev

This repository has my professional blog and the Nix files that configures the server on Digital Ocean.

## Infrastructure

All droplets run NixOS on DigitalOcean (nyc1 region), managed with Terraform (`IaC/`) and deployed with `deploy-rs`.

```mermaid
graph TB
    subgraph DigitalOcean["DigitalOcean (nyc1)"]
        subgraph VPC["VPC"]
            subgraph site["website (medium: 1vCPU/2GB)"]
                nginx[Nginx]
                nextcloud[Nextcloud 33]
                radicle[Radicle Node]
                antispam[Antispam Bot]
            end

            subgraph vpn["wireguard (small: 1vCPU/1GB)"]
                wg[WireGuard wg0]
            end

            subgraph znc_droplet["irc-bouncer (micro: 1vCPU/512MB)"]
                znc[ZNC Bouncer]
                saslauthd[saslauthd + PAM]
            end
        end
    end

    internet((Internet))
    client[IRC Client<br/>Halloy]
    devices[PC / Phone]

    internet -->|HTTPS :443| nginx
    internet -->|TCP :8776| radicle
    client -->|TLS :6697| znc
    devices -->|UDP :51820| wg
```

### Website Droplet (`vps.nix`)

Hosts the main web services behind Nginx with ACME certificates via DigitalOcean DNS.

```mermaid
graph LR
    subgraph Domains
        A[jorgearaya.dev]
        B[esavara.cr]
        C[nc.esavara.cr]
        D[misc.jorgearaya.dev]
        E[jardin.jorgearaya.dev]
    end

    subgraph Services
        nginx[Nginx]
        nc[Nextcloud 33<br/>SQLite + Redis]
        rad[Radicle<br/>httpd + node]
        bot[Antispam Bot<br/>Telegram]
    end

    A --> nginx
    B --> nginx
    C --> nc
    D --> nginx
    E --> rad
```

### VPN Droplet (`vpn.nix`)

WireGuard VPN server with IP forwarding for routing between peers.

```mermaid
graph LR
    subgraph WireGuard["wg0 (10.100.0.0/24)"]
        server["VPN Server<br/>10.100.0.1"]
        pc["PC<br/>10.100.0.2"]
        phone["Phone<br/>10.100.0.3"]
    end

    pc <-->|preshared key| server
    phone <-->|preshared key| server
    pc <-.->|routed via VPS| phone
```

### ZNC Droplet (`znc.nix`)

IRC bouncer connecting to multiple networks. See [etc/notes/znc.md](etc/notes/znc.md) for details.

## Deployment

```sh
# Deploy a specific node
nix run github:serokell/deploy-rs .#site
nix run github:serokell/deploy-rs .#vpn
nix run github:serokell/deploy-rs .#znc
```

## Notes

How to make a new Digital Ocean image:

```sh
nix build .#digital-ocean
```

### Secrets

Secrets are provided with this repository and installed after Digital Ocean has created the droplet. They cannot be installed on the Digital Ocean image on creation (AFAIK) thus we need to ssh into the server and generate the AGE key from the public SSH key of the system.

```sh
$ nix-shell -p ssh-to-age --run 'cat /etc/ssh/ssh_host_ed25519_key.pub | ssh-to-age'
```

After getting the AGE key, we have to update `.sops.yaml` and run `sops updatekeys` for the `secrets.yaml` file.

### Terraform

Infrastructure is managed in `IaC/`:

```sh
cd IaC
terraform plan
terraform apply
```

### ZNC

See [etc/notes/znc.md](etc/notes/znc.md) for post-deploy setup and Halloy configuration.
