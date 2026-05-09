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
    "wireguard/private_key" = { };
    "wireguard/preshared_keys/pc" = { };
    "wireguard/preshared_keys/phone" = { };
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

  # Enable IP forwarding so the VPS can route traffic between WireGuard peers
  # (e.g. Phone -> VPS -> PC for Jellyfin access)
  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
  };

  networking = {
    hostName = "wireguard";
    firewall = {
      enable = true;
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

  system.stateVersion = "24.11";
}
