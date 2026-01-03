{ config, pkgs, ... }:
{
  time.timeZone = "UTC";
  services.timesyncd.enable = true;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.supportedFilesystems = [ "nfs" ];
  services.rpcbind.enable = true;

  services.qemuGuest.enable = true;

  users.users.${config.homelab.adminUser} = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = config.homelab.sshKeys;
    hashedPassword = "!";
  };

  security.sudo.wheelNeedsPassword = false;

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
    settings.PermitRootLogin = "no";
  };

  environment.shellAliases = {
    k = "kubectl";
  };

  environment.systemPackages = with pkgs; [
    vim
    git
    htop
    curl
    wget
    kubectl
    nfs-utils
  ];

  nixpkgs.config.allowUnfree = true;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
}
