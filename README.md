# Homelab Setup

A NixOS-based homelab cluster running k3s on Proxmox.

## Architecture

- **k3s-master**: Master node running k3s server
- **media-worker**: Worker node running k3s agent with media storage

## Structure

- **`nixos/`**: NixOS flake configuration for both nodes

  - `hosts/master/`: Master node configuration
  - `hosts/worker/`: Worker node configuration
  - `modules/common.nix`: Shared configuration
  - `secrets.nix`: Secrets (not in git)

- **`apps/`**: Kubernetes manifests for deployed applications

  - jellyfin
  - sonarr
  - radarr
  - prowlarr
  - qbittorrent
  - flaresolverr
  - homepage

- **`bootstrap/`**: ArgoCD Application manifests for GitOps deployment

## Deployment

Applications are deployed via ArgoCD using the manifests in `bootstrap/`. Each application references the corresponding manifests in `apps/`.

## NixOS Configuration

Build and deploy NixOS configurations:

```bash
nixos-rebuild switch --flake .#k3s-master
nixos-rebuild switch --flake .#media-worker
```

Or build on a remote machine

```bash
 nix --extra-experimental-features "nix-command flakes" run github:numtide/nixos-anywhere -- --build-on-remote --flake .#k3s-master root@x.x.x.x
```
