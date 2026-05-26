{
  modulesPath,
  config,
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
    "users/root/hashed_password" = {
      neededForUsers = true;
    };
    "users/jorge/hashed_password" = {
      neededForUsers = true;
    };
  };

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

  # IP forwarding for subnet routing
  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
  };

  # Headscale - self-hosted Tailscale control server
  services.headscale = {
    enable = true;
    address = "0.0.0.0";
    port = 8080;

    settings = {
      server_url = "https://vpn.jorgearaya.dev";

      dns = {
        base_domain = "lan";
        magic_dns = true;
        nameservers.global = [
          "1.1.1.1"
          "9.9.9.9"
        ];
      };

      prefixes = {
        v4 = "100.64.0.0/10";
      };

      derp.server.enabled = false;

      database.type = "sqlite3";
      database.sqlite.path = "/var/lib/headscale/db.sqlite";

      logtail.enabled = false;
    };
  };

  # Nginx reverse proxy with TLS
  services.nginx = {
    enable = true;
    recommendedTlsSettings = true;
    recommendedProxySettings = true;

    virtualHosts."vpn.jorgearaya.dev" = {
      forceSSL = true;
      enableACME = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:8080";
        proxyWebsockets = true;
        extraConfig = ''
          proxy_buffering off;
          proxy_redirect http:// https://;
        '';
      };
    };
  };

  # ACME / Let's Encrypt
  security.acme = {
    acceptTerms = true;
    defaults.email = "jorge@jorgearaya.dev";
  };

  networking = {
    hostName = "headscale";
    firewall = {
      enable = true;
      allowedTCPPorts = [
        80 # ACME HTTP-01 challenge
        443 # HTTPS
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

  system.stateVersion = "24.11";
}
