# ZNC IRC Bouncer

## Architecture

Authentication via cyrusauth + saslauthd + PAM against system user `znc-admin`.

```mermaid
graph LR
    subgraph Auth
        halloy[Halloy Client] -->|TLS :6697| znc[ZNC]
        znc --> cyrusauth[cyrusauth]
        cyrusauth --> saslauthd
        saslauthd --> PAM
        PAM --> znc-admin[system user<br/>znc-admin]
    end

    subgraph Networks
        znc -->|SASL| libera[Libera.Chat]
        znc -->|SASL| oftc[OFTC]
        znc -->|SASL| rizon[Rizon]
        znc -->|perform| undernet[Undernet]
        znc -->|| efnet[EFnet]
    end
```

## Halloy Configuration

Connect to ZNC, not directly to IRC servers. Username format: `znc-admin/<network>`.

```toml
[servers.liberachat]
nickname = "shackra"
server = "znc.jorgearaya.dev"
port = 6697
use_tls = true
username = "znc-admin/liberachat"
password = "your-znc-password"

[servers.oftc]
nickname = "shackra"
server = "znc.jorgearaya.dev"
port = 6697
use_tls = true
username = "znc-admin/oftc"
password = "your-znc-password"

# Repeat for: undernet, rizon, efnet
```

## Post-deploy setup

### SASL (Libera.Chat, OFTC, Rizon)

From your IRC client, for each SASL-enabled network:

```
/msg *sasl set <nick> <password> PLAIN
```

### Undernet (perform module)

Undernet uses `X` service instead of NickServ:

```
/msg *perform add PRIVMSG X@channels.undernet.org :LOGIN <username> <password>
```

### EFnet

No nick registration — EFnet has no services. First come first served.

## ACME Certificate

ZNC uses a Let's Encrypt cert for `znc.jorgearaya.dev` via DigitalOcean DNS challenge. The ACME postRun script combines fullchain + key into `/var/lib/znc/znc.pem`. ZNC service waits for the ACME service before starting.

## Nick obfuscation

Nicks for undernet, rizon, and efnet are base64-encoded in `znc.nix` to prevent web crawlers from indexing them. Decoded at Nix evaluation time via `lib/base64.nix`.

To change a nick, encode it and update `znc.nix`:

```sh
echo -n "yournick" | base64
```
