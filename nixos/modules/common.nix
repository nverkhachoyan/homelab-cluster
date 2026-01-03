{ config, pkgs, ... }:
{
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.supportedFilesystems = [ "nfs" ];
  services.rpcbind.enable = true;

  services.qemuGuest.enable = true;

  networking.networkmanager.enable = true;

  users.users.${config.homelab.adminUser} = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" ];
    openssh.authorizedKeys.keys = config.homelab.sshKeys;
    hashedPassword = "!";
  };

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
    settings.PermitRootLogin = "no";
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
