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
        };
      in
      {
        formatter = pkgs.nixpkgs-fmt;

        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            kubeconform
            kubectl
            kubernetes-helm
            nixpkgs-fmt
            opentofu
            shellcheck
          ];

          shellHook = ''
            echo "--- NixOS Homelab Development Environment Loaded ---"

            onepassword_ssh_sock=""
            case "$(uname -s)" in
              Darwin)
                onepassword_ssh_sock="$HOME/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
                ;;
              Linux)
                onepassword_ssh_sock="$HOME/.1password/agent.sock"
                ;;
            esac

            if [ -n "$onepassword_ssh_sock" ] && [ -S "$onepassword_ssh_sock" ]; then
              export SSH_AUTH_SOCK="$onepassword_ssh_sock"
              export PROXMOX_VE_SSH_AUTH_SOCK="$onepassword_ssh_sock"
              echo "Using 1Password SSH agent."
            elif [ -n "$onepassword_ssh_sock" ]; then
              echo "1Password SSH agent socket not found; keeping existing SSH_AUTH_SOCK."
            fi

            unset onepassword_ssh_sock
          '';
        };
      });
}
