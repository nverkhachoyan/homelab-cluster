{ lib, ... }:

with lib;

{
  options.homelab = {
    masterIP = mkOption {
      type = types.str;
      description = "IP address of the k3s server node";
      default = "192.168.1.91";
    };

    adminUser = mkOption {
      type = types.str;
      description = "Primary admin user for the machines";
      default = "nverk";
    };

    sshKeys = mkOption {
      type = types.listOf types.str;
      description = "Authorized SSH public keys for the admin user";
      default = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBoVotkT+jNCRAtiZM+tQSh/grcNL17yldLsy1OhnsSb nverkhachoyan@iloveyou-2.local"
      ];
    };

  };
}
