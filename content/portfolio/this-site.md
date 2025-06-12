---
title: 'This Website 😎'
description: my professional website, powered by Hugo and Nix
project_description: A professional static website generated with Hugo and deployed with Nix
started: 2025
stopped: ""
relationship: author
cover: "/images/portfolio/this-site/jorgearayadev.png"
images: [/images/portfolio/this-site/jorgearayadev.png]
topics: [static site, Digital Ocean, Nginx, Let's Encrypt, GNU/Linux, NixOS]
programming_langs: [Nix]
tech: [Hugo, HTML, SCSS, NixOS]
draft: false
git: https://github.com/shackra/jorgeayara.dev/
weight: 110
---

I started this website for several reasons. First, to have a professional space on the web with content that could be useful to other software engineers and to showcase my experience in the field to potential clients. Second, as an exercise in "reproducibility."

By "reproducibility" I mean the ability for this website to be deployed anywhere and have the exact *bit-for-bit* same result as the original deployment. **And I don't just mean the content, but the entire technology stack.**

Despite my extensive experience with GNU/Linux, I’m not a *sysadmin* and I don’t particularly enjoy doing that kind of work, which is why I chose NixOS as the operating system for the Digital Ocean Droplet. NixOS is not just another GNU/Linux distribution like Arch or Debian; it’s a distribution whose configuration is expressed in a declarative way, allowing for the kind of "reproducibility" I mentioned earlier. For example, this is how I configured Nginx, Let’s Encrypt, and the directory where the static content lives:

```nix
{
  config,
  ...
}:
{
  # ...code omitted for brevity...
  systemd.tmpfiles.rules = [
    "d /var/www/jorgearaya.dev 0755 nginx nginx -"
  ];

  security.acme = {
    acceptTerms = true;
    defaults.email = "jorge+dns@esavara.cr";
    certs."jorgearaya.dev" = {
      dnsProvider = "digitalocean";
      environmentFile = config.sops.templates."acme.conf".path;
      webroot = null;
    };
  };

  services.nginx = {
    enable = true;
    commonHttpConfig = ''
      map $http_accept_language $preferred_lang {
        default en;
        ~^es es;
        ~^en en;
      }
    '';

    virtualHosts."jorgearaya.dev" = {
      enableACME = true;
      forceSSL = true;
      root = "/var/www/jorgearaya.dev";

      extraConfig = ''
        charset utf-8;
        error_page 404 = @localized_404;
      '';

      locations."/" = {
        tryFiles = "$uri $uri/ =404";
        extraConfig = ''
          if ($request_uri = "/") {
            return 302 /$preferred_lang/;
          }
        '';
      };

      # dynamic 404
      locations."@localized_404" = {
        extraConfig = ''
          if ($uri ~* "^/([a-z]{2})/") {
            set $lang $1;
          }

          if ($lang = "") {
            set $lang $preferred_lang;
          }

          rewrite ^ /$lang/404.html break;
        '';
      };
    };
  };
}
```

Let’s Encrypt and Nginx are exposed in NixOS as modules under `security.acme` and `services.nginx`, respectively. Some configuration properties for these services are provided by the modules as an attribute set. Attributes like `services.nginx.virtualHosts.<site>.extraConfig` are used to define additional configurations not covered by the module's default attributes.

With the Droplet configuration declared, deploying it in a new generation is just a matter of running `nix run github:serokell/deploy-rs .#`. If something goes wrong during deployment (for example, an error in the Nginx configuration that causes the systemd service to fail to start), the NixOS on the Droplet will simply roll back to the previous generation and continue working as if nothing happened.

To store the Digital Ocean API key for Let's Encrypt's "DNS Challenge," I use `sops-nix`, a NixOS module that leverages `sops` to provision secrets. The secret for the "DNS Challenge" is encrypted and stored in the repository alongside the server configuration. Only the `age` public keys registered in the `sops` config can decrypt and use the secret. Everything is nicely bundled together, making it very convenient!

If I want to keep my system up to date with the latest stable version of the NixOS software repository, all I have to do is refresh the inputs with `nix flake update` and deploy the same configuration using `deploy-rs`. Only having to use two commands is very convenient for server maintenance.

I hope to write more about Nix and NixOS on the blog, so that many of the terms I used in this project description will make more sense to the reader.
