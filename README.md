# Homelab Setup

A NixOS-based homelab cluster running k3s on Proxmox with GitOps via ArgoCD and external access via Cloudflare Tunnels.

## Architecture

- **k3s-master**: Master node running k3s server
- **media-worker**: Worker node running k3s agent with media storage

### Infrastructure Components

- **ArgoCD**: GitOps continuous delivery
- **MetalLB**: Bare-metal load balancer
- **Traefik**: Ingress controller
- **Cloudflare Tunnel**: Secure external access via `*.nver.me`

## Structure

```
homelab-cluster/
├── nixos/                  # NixOS flake configuration
│   ├── hosts/master/       # Master node config
│   ├── hosts/worker/       # Worker node config
│   ├── modules/            # Shared modules
│   └── secrets.nix         # Secrets (not in git)
├── infra/                  # Infrastructure components
│   ├── argocd/             # ArgoCD installation
│   ├── metallb/            # MetalLB load balancer
│   ├── traefik/            # Traefik ingress
│   └── cloudflare-tunnel/  # Cloudflare tunnel
├── apps/                   # Application manifests
│   ├── jellyfin/
│   ├── sonarr/
│   ├── radarr/
│   ├── prowlarr/
│   ├── qbittorrent/
│   ├── flaresolverr/
│   ├── homepage/
│   └── storage/
├── bootstrap/              # ArgoCD Applications
│   ├── root.yaml           # Root application (entry point)
│   ├── infra.yaml          # Infrastructure app-of-apps
│   ├── apps.yaml           # User apps app-of-apps
│   ├── infra/              # Individual infra apps
│   └── apps/               # Individual user apps
└── scripts/
    └── bootstrap.sh        # One-time cluster setup
```
