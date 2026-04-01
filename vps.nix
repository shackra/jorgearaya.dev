{
  modulesPath,
  config,
  pkgs,
  ...
}:

{
  imports = [ (modulesPath + "/virtualisation/digital-ocean-config.nix") ];

  nix = {
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
    };
    optimise.automatic = true;
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 8d";
    };
  };

  # sops-nix
  sops.defaultSopsFile = ./secrets.yaml;
  sops.defaultSopsFormat = "yaml";

  sops.secrets = {
    "digitalocean/do_auth_token" = { };
    "users/root/hashed_password" = {
      neededForUsers = true;
    };
    "users/jorge/hashed_password" = {
      neededForUsers = true;
    };
    "nextcloud/users/admin/password" = { };
    "wireguard/private_key" = { };
    "wireguard/preshared_keys/pc" = { };
    "wireguard/preshared_keys/phone" = { };
    "radicle/auth/privateKey" = { };
  };
  sops.templates."acme.conf".content = "DO_AUTH_TOKEN=${
    config.sops.placeholder."digitalocean/do_auth_token"
  }";

  users = {
    mutableUsers = false;
    users = {
      root = {
        hashedPasswordFile = config.sops.secrets."users/root/hashed_password".path;
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK0bpO5YAkdfhF+vPm2svNaEM52bezowcuzrOBejzbnw jorge@woody"
        ];
      };

      jorge = {
        createHome = true;
        hashedPasswordFile = config.sops.secrets."users/jorge/hashed_password".path;
        isNormalUser = true;
        extraGroups = [ "wheels" ];
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHigTrMGexf8aE9uPNsk2pOuGzjqQGz94sNMr5iPxrSd jorge@woody"
        ];
      };
    };
  };

  # Enable IP forwarding so the VPS can route traffic between WireGuard peers
  # (e.g. Phone -> VPS -> PC for Jellyfin access)
  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
  };

  networking = {
    hostName = "jorgearayadev";
    firewall = {
      enable = true;
      allowedTCPPorts = [
        443
      ];
      allowedUDPPorts = [
        51820 # WireGuard
      ];
    };
    wireguard.interfaces.wg0 = {
      ips = [ "10.100.0.1/24" ];
      listenPort = 51820;
      privateKeyFile = config.sops.secrets."wireguard/private_key".path;

      peers = [
        {
          # PC
          publicKey = "xAPHNBHdLLvuvjI4Nk/E733MaafC69xg3uiaXk5hKzA=";
          presharedKeyFile = config.sops.secrets."wireguard/preshared_keys/pc".path;
          allowedIPs = [ "10.100.0.2/32" ];
        }
        {
          # Phone
          publicKey = "K0lN1fPSG4SbV2vz8uqSXzt1eEuHKduogXO+MOza7Dg=";
          presharedKeyFile = config.sops.secrets."wireguard/preshared_keys/phone".path;
          allowedIPs = [ "10.100.0.3/32" ];
        }
      ];
    };
  };

  time.timeZone = "America/Costa_Rica";

  i18n.defaultLocale = "es_CR.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "es_CR.UTF-8";
    LC_IDENTIFICATION = "es_CR.UTF-8";
    LC_MEASUREMENT = "es_CR.UTF-8";
    LC_MONETARY = "es_CR.UTF-8";
    LC_NAME = "es_CR.UTF-8";
    LC_NUMERIC = "es_CR.UTF-8";
    LC_PAPER = "es_CR.UTF-8";
    LC_TELEPHONE = "es_CR.UTF-8";
    LC_TIME = "es_CR.UTF-8";
  };

  systemd.tmpfiles.rules = [
    "d /var/www/jorgearaya.dev 0755 nginx nginx -"
    "d /var/www/esavara.cr 0755 nginx nginx -"
    "d /var/www/esavara.cr/.well-known 0755 nginx nginx -"
    "d /var/www/misc.jorgearaya.dev 0755 nginx nginx -"
  ];

  security.acme = {
    acceptTerms = true;
    defaults.email = "jorge+dns@esavara.cr";
    certs."jorgearaya.dev" = {
      dnsProvider = "digitalocean";
      environmentFile = config.sops.templates."acme.conf".path;
      webroot = null;
    };
    certs."esavara.cr" = {
      dnsProvider = "digitalocean";
      environmentFile = config.sops.templates."acme.conf".path;
      webroot = null;
    };
    certs.${config.services.nextcloud.hostName} = {
      dnsProvider = "digitalocean";
      environmentFile = config.sops.templates."acme.conf".path;
      webroot = null;
    };
    certs."misc.jorgearaya.dev" = {
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

    virtualHosts."esavara.cr" = {
      enableACME = true;
      forceSSL = true;
      root = "/var/www/esavara.cr";

      extraConfig = ''
        charset utf-8;
      '';

      locations."/" = {
        tryFiles = "$uri $uri/ /index.html =404";
      };

      locations."/.well-known/nostr.json" = {
        extraConfig = ''
          default_type application/json;
          add_header Access-Control-Allow-Origin "*" always;
        '';
      };
    };

    virtualHosts.${config.services.nextcloud.hostName} = {
      forceSSL = true;
      enableACME = true;
    };

    virtualHosts."misc.jorgearaya.dev" = {
      enableACME = true;
      forceSSL = true;
      root = "/var/www/misc.jorgearaya.dev";

      locations."/" = {
        tryFiles = "$uri $uri/ =404";
      };
    };
  };

  services.nextcloud = {
    enable = true;
    package = pkgs.nextcloud33;
    hostName = "nc.esavara.cr";
    https = true;
    database.createLocally = true;
    config.adminpassFile = config.sops.secrets."nextcloud/users/admin/password".path;
    config.dbtype = "sqlite"; # NOTE: this is a single user instance
    # read in case you want to migrate: https://docs.nextcloud.com/server/latest/admin_manual/configuration_database/db_conversion.html

    extraApps = {
      inherit (config.services.nextcloud.package.packages.apps)
        news
        bookmarks
        forms
        ;
    };
    extraAppsEnable = true;

    settings = {
      mail_smtpmode = "sendmail";
      mail_sendmailmode = "pipe";
    };
    caching.redis = true;
  };

  security.acme.certs."jardin.jorgearaya.dev" = {
    dnsProvider = "digitalocean";
    environmentFile = config.sops.templates."acme.conf".path;
    webroot = null;
  };

  services.radicle = {
    enable = true;
    privateKeyFile = config.sops.secrets."radicle/auth/privateKey".path;
    publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFZQ3w70MJIqT+Eb4jnu6tGeeecTM0AnSKC+ylbPxtoA radicle";
    node.openFirewall = true;
    node.listenAddress = "0.0.0.0";
    settings = {
      node = {
        alias = "jardin.jorgearaya.dev";
        externalAddresses = [ "jardin.jorgearaya.dev:8776" ];
        seedingPolicy = {
          default = "block";
        };
        connect = [
          "z6MknSLrJoTcukLrE435hVNQT4JUhbvWLX4kUzqkEStBU8Vi@seed.radicle.garden:8776"
          "z6MksmpU5b1dS7oaqF2bHXhQi1DWy2hB7Mh9CuN7y1DN6QSz@seed.radicle.xyz:58776"
          "z6MkrLMMsiPWUcNPHcRajuMi9mDfYckSoJyPwwnknocNYPm7@iris.radicle.xyz:58776"
        ];
      };
      web = {
	pinned = {
          repositories = [
            "rad:z39RJHSHs166S5kr8Qstj6kd1LFah" # Goimapnotify
	    "rad:z3mUnND1ZXQaLhSAcf26SFmdJ6sCh" # liber-modestus
	    "rad:z2yWgtRWDbdZqzJGEfWDi9NetLZ7o" # The Rule
          ];
        };
        bannerUrl = "https://misc.jorgearaya.dev/Flores%20de%20Navidad%20por%20Claude%20Monet.jpg";
        description = "🇪🇸 Proyectos personales (públicos y privados) de Jorge Javier Araya Navarro (c.c. Shackra). 🇺🇸 Personal projects (public and private) by Jorge Javier Araya Navarro (a.k.a. Shackra)";
      };
    };
    httpd.enable = true;
    httpd.nginx.serverName = "jardin.jorgearaya.dev";
    httpd.nginx.enableACME = true;
    httpd.nginx.forceSSL = true;
  };

  system.stateVersion = "24.11";
}
