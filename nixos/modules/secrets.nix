{ config, lib, ... }:

with lib;

{
  options.secrets = {
    sshKey = mkOption {
      type = types.str;
      description = "SSH public key for the user";
    };

    userPassword = mkOption {
      type = types.str;
      description = "Hashed password for the user";
    };

    k3sToken = mkOption {
      type = types.str;
      description = "K3s cluster token";
    };

    mediaDriveUUID = mkOption {
      type = types.str;
      description = "UUID of the media drive";
    };
  };

  options.cluster = {
    masterIP = mkOption {
      type = types.str;
      description = "IP address of the master node";
    };

    workerIP = mkOption {
      type = types.str;
      description = "IP address of the worker node";
    };

    gateway = mkOption {
      type = types.str;
      description = "Gateway IP address";
    };

    domain = mkOption {
      type = types.str;
      description = "Cluster domain";
    };

    username = mkOption {
      type = types.str;
      description = "Username for the system user";
    };

    installMode = mkOption {
      type = types.bool;
      description = "Whether to run in install mode";
      default = false;
    };
  };
}

