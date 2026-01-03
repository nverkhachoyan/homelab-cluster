{ config, pkgs, ... }:
{
  networking.hostName = "media-worker";

  services.k3s = {
    enable = true;
    role = "agent";
    tokenFile = "/etc/k3s/token";
    serverAddr = "https://${config.homelab.masterIP}:6443";
  };
}
