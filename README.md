# Homelab Setup

A NixOS-based homelab cluster running k3s on Proxmox with GitOps via ArgoCD and external access via Cloudflare Tunnels.

## Architecture

- **k3s-master**: Master node running k3s server
- **media-worker**: Worker node running k3s agent with media storage

### Infrastructure Components

- **ArgoCD**: GitOps continuous delivery
- **MetalLB**: Bare-metal load balancer
- **Traefik**: Ingress controller
- **Cloudflare Tunnel**: Secure external access via `*.nverk.me`

## Structure

```
homelab-cluster/
├── kubernetes/                # All Kubernetes + GitOps content
│   ├── bootstrap/             # ArgoCD Applications (app-of-apps)
│   │   ├── root.yaml          # Root application (entry point)
│   │   ├── infra.yaml         # Platform app-of-apps
│   │   ├── apps.yaml          # Workloads app-of-apps
│   │   ├── infra/             # Individual platform apps
│   │   └── apps/              # Individual workload apps
│   ├── platform/              # Platform components (argocd, sealed-secrets, 1password, etc.)
│   └── workloads/             # Workload manifests (jellyfin, sonarr, radarr, prowlarr, qbittorrent, flaresolverr, homepage, storage)
├── nixos/                     # NixOS flake configuration
│   ├── hosts/master/          # Master node config
│   ├── hosts/worker/          # Worker node config
│   ├── modules/               # Shared modules
│   └── secrets.nix            # Secrets (not in git)
└── scripts/
    └── bootstrap.sh           # One-time cluster setup
```
