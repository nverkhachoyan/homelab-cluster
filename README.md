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
│   │   ├── platform.yaml         # Platform app-of-apps
│   │   ├── apps.yaml          # Workloads app-of-apps
│   │   ├── platform/             # Individual platform apps
│   │   └── apps/              # Individual workload apps
│   ├── platform/              # Platform components (argocd, sealed-secrets, 1password, etc.)
│   └── workloads/             # Workload manifests (jellyfin, sonarr, radarr, prowlarr, qbittorrent, flaresolverr, homepage, storage)
├── nixos/                     # NixOS flake configuration
│   ├── hosts/master/          # Master node config
│   ├── hosts/worker/          # Worker node config
│   ├── modules/               # Shared modules + homelab settings options
│   ├── settings.example.nix   # Template for required values
│   └── settings.nix           # Local settings (gitignored)
└── scripts/
    └── bootstrap.sh           # One-time cluster setup

## Settings (no baked secrets)

- Copy `nixos/settings.example.nix` to `nixos/settings.nix` and fill in your values; the file is gitignored.
- Or point to an external file with `NIXOS_SETTINGS_FILE=/absolute/path/to/settings.nix` before running Nix commands.
- Required keys: `masterIP`, `adminUser`, `sshKeys` (public), `mediaDriveUUID`, `installMode`.
- SSH is key-only by default (password locked). Set a password later via console if needed.
- k3s token is not baked into the image; after the server boots, copy `/var/lib/rancher/k3s/server/node-token` from the master to `/etc/k3s/token` on the worker and restart the agent.
```
