{
  description = "My NixOS Homelab";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfreePredicate = pkg:
            builtins.elem (nixpkgs.lib.getName pkg) [
              "1password-cli"
            ];
        };
      in
      {
        formatter = pkgs.nixpkgs-fmt;

        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            _1password-cli
            jq
            kubeconform
            kubectl
            kubernetes-helm
            nixpkgs-fmt
            shellcheck
            yq-go
          ];

          shellHook = ''
            echo "--- NixOS Homelab Development Environment Loaded ---"
          '';
        };
      });
}
