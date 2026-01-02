# Homelab Cluster Cheat Sheet

## Overview

- K3s on NixOS (Proxmox VMs) managed via ArgoCD (app-of-apps under `bootstrap/`).
- Ingress: Traefik (Helm chart via Argo) + Cloudflare Tunnel wildcard `*.nverk.me` terminating to Traefik service.
- Load balancing: MetalLB with pool `192.168.1.200-192.168.1.210`.
- Secrets: 1Password Connect (official Helm chart) + External Secrets + Homelab vault items. Bootstrap credentials/tokens are sealed secrets in git; everything else syncs from 1Password.

## Layout

```
bootstrap/            # ArgoCD root + infra/apps app-of-apps
  root.yaml           # points to bootstrap/{infra,apps}
  infra/              # Argo Applications for infra components (sealed-secrets, 1Password Connect, external-secrets, op-secretstore, metallb, traefik, cloudflare-tunnel)
  apps/               # Argo Applications for workloads (jellyfin, sonarr, radarr, prowlarr, qbittorrent, homepage, flaresolverr, storage)
infra/                # Infra manifests (kustomize) and Helm values
apps/                 # Workload manifests (Deployment/Service/Ingress/etc.)
nixos/                # VM OS config for k3s nodes
```

## Infra Components

- **Sealed Secrets**: installs controller; bootstrap secrets are in `infra/onepassword-connect/sealedsecret-*.yaml`.
- **1Password Connect**: `infra/onepassword-connect` (Helm via kustomize `helmCharts`). Values in `values.yaml`. Token/credentials sealed; operator disabled.
- **External Secrets**: Helm chart installs CRDs/operator. `infra/op-secretstore` defines `ClusterSecretStore op-connect` pointing to Connect API.
- **MetalLB**: `infra/metallb` with IPAddressPool `192.168.1.200-192.168.1.210` and L2Advertisement.
- **Traefik**: ArgoCD Application using the official Helm chart; LoadBalancer service (handled by MetalLB).
- **Cloudflare Tunnel**: `infra/cloudflare-tunnel`; configmap points `*.nverk.me` to Traefik service. Token is synced from 1Password via ExternalSecret.

## Secrets Flow

1. Sealed secrets provide the Connect bootstrap credential/token.
2. 1Password Connect API/Sync deploys from Helm.
3. ClusterSecretStore `op-connect` (namespace `onepassword`) references the Connect token secret.
4. ExternalSecrets:
   - `infra/cloudflare-tunnel/externalsecret.yaml` → Secret `cloudflare-tunnel-token` (Homelab item `cloudflare-tunnel`, property `credential`).
   - `apps/homepage/externalsecret.yaml` → Secret `homepage-secrets` (items `jellyfin`, `radarr`, `sonarr`, `prowlarr`, `qbittorrent`, property `credential`).
     No manual `kubectl create secret` needed; keep Homelab vault items updated in 1Password.

## Domain/Ingress

- DNS: `*.nverk.me` CNAME to Cloudflare Tunnel ID.
- Cloudflared forwards all hosts to `http://traefik.traefik.svc.cluster.local:80`.
- Ingress hosts:
  - Homepage: `home.nverk.me`
  - Jellyfin: `jellyfin.nverk.me`
  - Sonarr: `sonarr.nverk.me`
  - Radarr: `radarr.nverk.me`
  - Prowlarr: `prowlarr.nverk.me`
  - qBittorrent: `torrent.nverk.me`

## Current Status (last verified)

- ArgoCD apps synced; Connect/ExternalSecrets healthy; Cloudflare Tunnel healthy.
- Secrets populated automatically (`cloudflare-tunnel-token`, `homepage-secrets` present).
- All app ingresses use `*.nverk.me` and route via Traefik → workloads.

## Useful Commands

```bash
# Argo apps and health
kubectl -n argocd get applications

# External Secrets status
kubectl get externalsecret -A

# 1Password Connect pods/logs
kubectl -n onepassword get pods
kubectl -n onepassword logs deploy/onepassword-connect -c connect-sync --tail=50

# Cloudflare tunnel logs
kubectl -n cloudflare logs deploy/cloudflared --tail=50
```
