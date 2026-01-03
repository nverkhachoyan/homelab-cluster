{
  description = "Homelab Setup";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
    nixos-generators.url = "github:nix-community/nixos-generators";
    nixos-generators.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, disko, nixos-generators, ... }:
    let
      baseModules = [
        disko.nixosModules.disko
        ./modules/settings.nix
        ./modules/hardware.nix
        ./modules/common.nix
      ];

      masterModules = baseModules ++ [
        ./hosts/master/configuration.nix
        ./modules/disks.nix
      ];

      workerModules = baseModules ++ [
        ./hosts/worker/configuration.nix
        ./modules/disks.nix
      ];

      generateProxmoxImage = modules:
        nixos-generators.nixosGenerate {
          system = "x86_64-linux";
          modules =
            modules
            ++ [
              {
                proxmox.qemuConf.bios = "ovmf";
                proxmox.partitionTableType = "efi";
                proxmox.cloudInit.enable = false;
                disko.enableConfig = false;
              }
            ];
          format = "proxmox";
        };
    in
    {
      nixosConfigurations = {

        k3s-master = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = masterModules;
        };

        k3s-worker = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = workerModules;
        };

      };

      packages.x86_64-linux = {
        k3s-master-proxmox = generateProxmoxImage masterModules;
        k3s-worker-proxmox = generateProxmoxImage workerModules;
      };
    };
}
