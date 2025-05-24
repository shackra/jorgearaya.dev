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
    "digitalocean/do_auth_token" = { };
  };
  sops.templates."acme.conf".content = ''
    DO_AUTH_TOKEN=${config.sops.placeholder."digitalocean/do_auth_token"}
  '';

  networking = {
    hostName = "jorgearayadev";
    firewall = {
      enable = true;
      allowedTCPPorts = [
        443
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
    virtualHosts."jorgearaya.dev" = {
      enableACME = true;
      forceSSL = true;
      root = "/var/www/jorgearaya.dev";

      extraConfig = ''
        error_page 404 /404.html;
        charset utf-8;
      '';

      locations."/" = {
        tryFiles = "$uri $uri/ =404";
      };
    };
  };

  system.stateVersion = "24.11";
}
