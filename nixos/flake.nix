{
  description = "Homelab Setup";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-generators.url = "github:nix-community/nixos-generators";
    nixos-generators.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, nixos-generators, ... }:
    let
      baseModules = [
        ./modules/settings.nix
        ./modules/hardware.nix
        ./modules/common.nix
      ];

      masterModules = baseModules ++ [
        ./hosts/master/configuration.nix
      ];

      workerModules = baseModules ++ [
        ./hosts/worker/configuration.nix
      ];

      proxmoxImageModule = {
        proxmox.qemuConf.bios = "ovmf";
        proxmox.partitionTableType = "efi";
        proxmox.cloudInit.enable = true;
        proxmox.qemuConf.cores = 2;
        proxmox.qemuConf.memory = 4096;
        virtualisation.diskSize = 32 * 1024;
      };

      generateProxmoxImage = modules:
        nixos-generators.nixosGenerate {
          system = "x86_64-linux";
          modules = modules ++ [ proxmoxImageModule ];
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
