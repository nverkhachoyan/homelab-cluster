{ config, pkgs, ... }:
{
  services.k3s = {
    enable = true;
    role = "agent";
    extraFlags = [
      "--node-label=role=worker"
    ];
    tokenFile = "/etc/k3s/token";
    serverAddr = "https://${config.homelab.masterIP}:6443";
  };

  networking.firewall = {
  enable = true;
  allowedUDPPorts = [ 8472 51820 51821 ]; 
  allowedTCPPorts = [ 6443 10250 ];
};

  systemd.tmpfiles.rules = [
    "d /etc/k3s 0700 root root -"
    "f /etc/k3s/token 0600 root root - REPLACE_ME_WITH_TOKEN"
  ];


  system.stateVersion = "24.05";
}
