{
  modulesPath,
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

    users = {
    mutableUsers = false;
    users = {
      root = {
        hashedPassword = "$y$j9T$FDKcwMo1SX3.G6c83pD0v0$Y2AZfyoduH4P2qB4MRUMpIXAVvkkTk5sNHtxgP6sKv0";
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK0bpO5YAkdfhF+vPm2svNaEM52bezowcuzrOBejzbnw jorge@woody"
        ];
      };
    };
  };

  system.stateVersion = "24.11";
}
