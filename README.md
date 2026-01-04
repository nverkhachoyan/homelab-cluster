# Homelab Setup

A NixOS-based homelab cluster running k3s on Proxmox with GitOps via ArgoCD and external access via Cloudflare Tunnels.

## Architecture

- **k3s-master**: Master node running k3s server
- **media-workers**: Worker nodes running k3s agents with media storage

### Infrastructure Components

- **ArgoCD**: GitOps continuous delivery
- **MetalLB**: Bare-metal load balancer
- **Traefik**: Ingress controller
- **Cloudflare Tunnel**: Secure external access via `*.nverk.me`

## Structure

### `kubernetes/`

All Kubernetes + GitOps content. Contains `bootstrap/` (ArgoCD app-of-apps), `platform/` (argocd, cloudflare, etc.), and `workloads/` (storage, jellyfin, sonarr, radarr, prowlarr, etc).

### `nixos/`

NixOS flake configs for building VMs.

### `scripts/`

Utility scripts (e.g. secret generation).

### Steps

1. Deploy argocd first.

```sh
kubectl apply -k "kubernetes/platform/argocd"
```

2. Wait argocd to deploy, and run the bootstrap.

```sh
kubectl apply -f "kubernetes/bootstrap/root.yaml"
```
