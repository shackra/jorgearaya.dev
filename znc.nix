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
    "znc/hash" = { };
    "znc/salt" = { };
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
      LoadModule = [ "adminlog" ];
      User.shackra = {
        Admin = true;
        Nick = "shackra";
        AltNick = "shackra_";
        Ident = "shackra";
        RealName = "Jorge Araya";
        LoadModule = [ "chansaver" "controlpanel" ];
        Pass.password = {
          Method = "SHA256";
          Hash = {
            _secret = config.sops.secrets."znc/hash".path;
          };
          Salt = {
            _secret = config.sops.secrets."znc/salt".path;
          };
        };
        Network.liberachat = {
          Server = "irc.libera.chat +6697";
          LoadModule = [ "simple_away" "keepnick" "savebuff" ];
          Chan = {
            "#nixos" = { };
          };
        };
        Network.oftc = {
          Server = "irc.oftc.net +6697";
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
