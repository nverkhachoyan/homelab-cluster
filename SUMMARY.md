# Homelab Setup Session Summary

## What We Built

A GitOps-based homelab infrastructure using:

- **K3s** on NixOS (Proxmox VMs)
- **ArgoCD** for GitOps continuous deployment
- **MetalLB** for load balancing (pending fix)
- **Traefik** as ingress controller ✅ Running
- **Cloudflare Tunnels** for external access via `*.nver.me` (troubleshooting)

## Directory Structure Created

```
homelab-cluster/
├── infra/                      # Infrastructure components
│   ├── argocd/                 # ArgoCD installation (kustomize)
│   ├── metallb/                # MetalLB load balancer
│   ├── traefik/                # (deleted - now inline in ArgoCD app)
│   └── cloudflare-tunnel/      # Cloudflared deployment
├── bootstrap/
│   ├── root.yaml               # Root ArgoCD Application
│   ├── infra.yaml              # App-of-apps for infrastructure
│   ├── apps.yaml               # App-of-apps for user apps
│   ├── infra/                  # Individual infra apps
│   │   ├── metallb.yaml
│   │   ├── traefik.yaml        # Uses Helm chart directly
│   │   └── cloudflare-tunnel.yaml
│   └── apps/                   # Individual user apps
│       ├── jellyfin.yaml
│       ├── sonarr.yaml
│       ├── radarr.yaml
│       ├── prowlarr.yaml
│       ├── qbittorrent.yaml
│       ├── homepage.yaml
│       ├── flaresolverr.yaml
│       └── storage.yaml
├── apps/                       # Application manifests
│   └── storage/
│       ├── media-pv.yaml       # NFS PersistentVolume
│       └── media-pvc.yaml      # NFS PersistentVolumeClaim
└── scripts/
    └── bootstrap.sh            # One-time cluster setup
```

## Key Changes Made

### 1. Infrastructure Setup

- Created ArgoCD kustomization to install from official manifests
- Created MetalLB configuration with IP pool `192.168.1.200-192.168.1.210`
- Set up Traefik via ArgoCD Helm source (not kustomize)
- Created Cloudflared deployment for Cloudflare Tunnels

### 2. App Updates

- Updated all ingress resources to use `*.nver.me` subdomains
- Updated Homepage configmap with new URLs
- Fixed nodeSelector from `k3s-master-01` to `k3s-master`
- Updated Jellyfin's `JELLYFIN_PublishedServerUrl` to `https://jellyfin.nver.me`

### 3. Storage (NFS)

- Created NFS-based PersistentVolume pointing to Proxmox NFS share at `192.168.1.3:/mnt/media`
- Updated PVC to use ReadWriteMany with NFS

### 4. NixOS Updates

- Added NFS client support (`boot.supportedFilesystems`, `services.rpcbind`, `nfs-utils`)
- Added QEMU Guest Agent for Proxmox (`services.qemuGuest.enable`)
- Removed unused `cloudflareTunnelToken` from secrets (managed via kubectl)

## Current Status

| Component             | Status       | Notes                                       |
| --------------------- | ------------ | ------------------------------------------- |
| ArgoCD                | ✅ Running   | Accessible via port-forward                 |
| Traefik               | ✅ Running   | Ingress controller working                  |
| MetalLB               | ❌ Unknown   | Kustomize URL issue - needs fix             |
| Cloudflared           | ⚠️ CrashLoop | "context canceled" - trying HTTP/2 protocol |
| Apps (Jellyfin, etc.) | ✅ Running   | All 7 apps running                          |
| Homepage              | ✅ Running   | Needs API keys in secret                    |

## Manual Steps Required

### 1. Cloudflare Tunnel Secret
- Managed via SealedSecrets (`infra/cloudflare-tunnel/sealedsecret.yaml`).
- Rotate by re-sealing a new token with `kubeseal --scope namespace-wide --cert <controller-cert> < secret.yaml` and committing the updated sealed secret.

### 2. Homepage Secrets (for widgets)

```bash
kubectl create secret generic homepage-secrets \
  --from-literal=jellyfin_key='YOUR_KEY' \
  --from-literal=radarr_key='YOUR_KEY' \
  --from-literal=sonarr_key='YOUR_KEY' \
  --from-literal=prowlarr_key='YOUR_KEY' \
  --from-literal=qbit_password='YOUR_PASSWORD'
```

### 3. Cloudflare Dashboard Configuration

1. Create tunnel in Zero Trust → Networks → Tunnels
2. Add public hostnames (e.g., `jellyfin.nver.me` → `http://traefik.traefik.svc.cluster.local:80`)
3. Add wildcard DNS: `*.nver.me` CNAME to `<tunnel-id>.cfargotunnel.com`

## Outstanding Issues

### MetalLB Not Syncing

The kustomize remote resource URL needs to be fixed. Current error: can't fetch from GitHub.

**Potential fix**: Download manifests locally or use a different URL format.

### Cloudflared Crashing

The tunnel connects but immediately gets "context canceled".

**Things tried**:

- Token mode (works, connects)
- Removed liveness probes
- Switched to HTTP/2 protocol
- Increased memory limits

**Possible causes**:

- Network/firewall blocking connections
- Tunnel misconfiguration in Cloudflare dashboard
- Need to check Cloudflare dashboard for errors

## Useful Commands

```bash
# Check all pods
kubectl get pods -A

# Check ArgoCD apps
kubectl get applications -n argocd

# Access ArgoCD UI
kubectl port-forward svc/argocd-server -n argocd 8080:443 --address 0.0.0.0

# Get ArgoCD password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d

# Check cloudflared logs
kubectl logs -n cloudflare -l app=cloudflared

# Force app refresh
kubectl delete application <app-name> -n argocd
```

## App URLs (once working)

| App         | URL                      |
| ----------- | ------------------------ |
| Homepage    | https://home.nver.me     |
| Jellyfin    | https://jellyfin.nver.me |
| Sonarr      | https://sonarr.nver.me   |
| Radarr      | https://radarr.nver.me   |
| Prowlarr    | https://prowlarr.nver.me |
| qBittorrent | https://torrent.nver.me  |
