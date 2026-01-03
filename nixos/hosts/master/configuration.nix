{ config, pkgs, ... }:
{
  networking.hostName = "k3s-master";

  services.k3s = {
    enable = true;
    role = "server";
    extraFlags = toString [
      "--write-kubeconfig-mode 644"
      "--disable traefik"
      "--disable servicelb"
      "--flannel-backend=host-gw"
    ];
  };

  networking.firewall.allowedTCPPorts = [ 6443 ];
  networking.firewall.allowedUDPPorts = [ 8472 ];

  system.stateVersion = "24.05";
}
