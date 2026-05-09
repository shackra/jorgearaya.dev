{
  modulesPath,
  config,
  pkgs,
  ...
}:

let
  nicks = import ./irc-nicks.nix;
in
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
    "znc/password" = {
      neededForUsers = true;
    };
    "digitalocean/do_auth_token" = { };
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

      "znc-admin" = {
        isSystemUser = true;
        group = "znc-admin";
        hashedPasswordFile = config.sops.secrets."znc/password".path;
      };
    };
    groups."znc-admin" = { };
  };

  # cyrusauth talks to saslauthd, which authenticates via PAM
  services.saslauthd.enable = true;

  environment.etc."pam.d/znc" = {
    source = pkgs.writeText "znc.pam" ''
      account required pam_unix.so
      auth sufficient pam_unix.so likeauth try_first_pass
      auth required pam_deny.so
      password sufficient pam_unix.so nullok sha512
      session required pam_env.so conffile=/etc/pam/environment readenv=0
      session required pam_unix.so
    '';
  };

  # allow ZNC service to talk to saslauthd's unix socket
  systemd.services.znc.serviceConfig.RestrictAddressFamilies = [ "AF_UNIX" ];
  # ensure ACME cert is ready before ZNC starts
  systemd.services.znc.after = [ "acme-znc.jorgearaya.dev.service" ];
  systemd.services.znc.wants = [ "acme-znc.jorgearaya.dev.service" ];

  security.acme = {
    acceptTerms = true;
    defaults.email = "jorge+dns@esavara.cr";
    certs."znc.jorgearaya.dev" = {
      dnsProvider = "digitalocean";
      environmentFile = config.sops.templates."acme.conf".path;
      webroot = null;
      group = "znc";
      # combine cert + key into ZNC's expected pem format
      postRun = ''
        cat ${config.security.acme.certs."znc.jorgearaya.dev".directory}/fullchain.pem \
            ${config.security.acme.certs."znc.jorgearaya.dev".directory}/key.pem \
            > /var/lib/znc/znc.pem
        chown znc:znc /var/lib/znc/znc.pem
        chmod 600 /var/lib/znc/znc.pem
        systemctl restart znc
      '';
    };
  };

  networking = {
    hostName = "irc-bouncer";
    firewall = {
      enable = true;
      allowedTCPPorts = [
        6697 # ZNC IRC
      ];
    };
  };

  services.znc = {
    enable = true;
    useLegacyConfig = false;
    mutable = false;
    openFirewall = true;

    config = {
      LoadModule = [ "adminlog" "cyrusauth saslauthd" ];
      User."znc-admin" = {
        Admin = true;
        Nick = "shackra";
        AltNick = "shackra_";
        Ident = "shackra";
        RealName = "Jorge Araya";
        LoadModule = [ "chansaver" "controlpanel" ];
        Pass = "md5#::#::#"; # fake hash — auth via SASL/PAM only
        Network.liberachat = {
          Server = "irc.libera.chat +6697";
          LoadModule = [ "simple_away" "keepnick" "savebuff" "sasl" ];
          Chan = {
            "#nixos" = { };
            "#nixos-dev" = { };
            "#linux" = { };
            "#libera" = { };
            "#archlinux" = { };
            "#python" = { };
            "#kde" = { };
            "#lobsters" = { };
            "##rust" = { };
            "#security" = { };
            "##programming" = { };
            "#bash" = { };
            "#git" = { };
            "#hardware" = { };
            "#go-nuts" = { };
            "#zig" = { };
            "#emacs" = { };
            "#emacs-beginners" = { };
            "#c" = { };
            "#c++" = { };
          };
        };
        Network.oftc = {
          Server = "irc.oftc.net +6697";
          Nick = "shackra_";
          AltNick = "shackra__";
          Ident = "shackra_";
          LoadModule = [ "simple_away" "keepnick" "savebuff" "sasl" ];
          Chan = {
            "#fdroid" = { };
          };
        };
        Network.undernet = {
          Server = "irc.undernet.org +6697";
          Nick = nicks.undernet;
          AltNick = "${nicks.undernet}_";
          Ident = nicks.undernet;
          LoadModule = [ "simple_away" "keepnick" "savebuff" "perform" ];
        };
        Network.rizon = {
          Server = "irc.rizon.net +6697";
          Nick = nicks.rizon;
          AltNick = "${nicks.rizon}_";
          Ident = nicks.rizon;
          LoadModule = [ "simple_away" "keepnick" "savebuff" "sasl" ];
        };
        Network.efnet = {
          Server = "irc.efnet.org +6697";
          Nick = nicks.efnet;
          AltNick = "${nicks.efnet}_";
          Ident = nicks.efnet;
          LoadModule = [ "simple_away" "keepnick" "savebuff" ];
        };
      };
      Listener.l = {
        Port = 6697;
        IPv4 = true;
        IPv6 = false;
        SSL = true;
        AllowWeb = false;
      };
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
