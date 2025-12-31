{
  description = "Homelab Setup";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, disko, ... }:
    let
      vars =
        if builtins.pathExists ./secrets.nix
        then import ./secrets.nix
        else import ./secrets.example.nix;
    in
    {
      nixosConfigurations = {

        k3s-master = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            disko.nixosModules.disko
            ./modules/secrets.nix
            ./modules/common.nix
            ./hosts/master/configuration.nix
            ./hosts/master/disks.nix
            {
              secrets.sshKey = vars.sshKey;
              secrets.userPassword = vars.userPassword;
              secrets.k3sToken = vars.k3sToken;
              secrets.mediaDriveUUID = vars.mediaDriveUUID;
              cluster.masterIP = vars.masterIP;
              cluster.workerIP = vars.workerIP;
              cluster.gateway = vars.gateway;
              cluster.domain = vars.domain;
              cluster.username = vars.username;
              cluster.installMode = vars.installMode;
            }
          ];
        };

        media-worker = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            disko.nixosModules.disko
            ./modules/secrets.nix
            ./modules/common.nix
            ./hosts/worker/configuration.nix
            ./hosts/worker/disks.nix
            {
              secrets.sshKey = vars.sshKey;
              secrets.userPassword = vars.userPassword;
              secrets.k3sToken = vars.k3sToken;
              secrets.mediaDriveUUID = vars.mediaDriveUUID;
              cluster.masterIP = vars.masterIP;
              cluster.workerIP = vars.workerIP;
              cluster.gateway = vars.gateway;
              cluster.domain = vars.domain;
              cluster.username = vars.username;
              cluster.installMode = vars.installMode;
            }
          ];
        };

      };
    };
}
