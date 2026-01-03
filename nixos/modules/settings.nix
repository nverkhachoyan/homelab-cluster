{ lib, ... }:

with lib;

{
  options.homelab = {
    masterIP = mkOption {
      type = types.str;
      description = "IP address of the k3s server node";
    };

    adminUser = mkOption {
      type = types.str;
      description = "Primary admin user for the machines";
    };

    sshKeys = mkOption {
      type = types.listOf types.str;
      description = "Authorized SSH public keys for the admin user";
      default = [ ];
    };

    installMode = mkOption {
      type = types.bool;
      description = "If true, skip mounting media drive to ease initial install";
      default = false;
    };
  };
}
