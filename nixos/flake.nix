{
  description = "Homelab Setup";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, disko, ... }:
    let

    in
    {
      nixosConfigurations = {

        k3s-master = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            disko.nixosModules.disko
            ./modules/settings.nix
            ./modules/hardware.nix
            ./modules/common.nix
            ./hosts/master/configuration.nix
            ./modules/disks.nix
          ];
        };

        media-worker = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            disko.nixosModules.disko
            ./modules/settings.nix
            ./modules/hardware.nix
            ./modules/common.nix
            ./hosts/worker/configuration.nix
            ./modules/disks.nix
          ];
        };

      };
    };
}
