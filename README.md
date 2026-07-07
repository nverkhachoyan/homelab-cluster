# Homelab k3s Cluster

Minimal homelab setup for media workloads

## Stack

- Platform: MetalLB, Traefik, Cloudflared
- Workloads: Radarr, Sonarr, Readarr, Prowlarr, FlareSolverr, Jellyfin, Jellyseerr, Kavita, qBittorrent, Filebrowser
- Network privacy: qBittorrent runs through a Gluetun sidecar using Proton VPN WireGuard and Proton VPN port forwarding
- Storage:
  - Shared media data on NFS (`media-pv` / `media-pvc`)
  - App config PVCs on k3s `local-path`
- Proxmox: OpenTofu definitions for brownfield VM import under `proxmox/opentofu/`

## Structure

- `kubernetes/platform/`: infrastructure manifests and top-level platform kustomization
- `kubernetes/workloads/`: media namespace, storage, app manifests, and top-level workload kustomization
- `kubernetes/scripts/apply_secrets.sh`: creates Kubernetes Secrets from local environment variables
- `kubernetes/scripts/render-traefik.sh`: renders the Traefik Helm chart
- `kubernetes/scripts/validate.sh`: renders platform, Traefik, and workload manifests
- `kubernetes/scripts/deploy.sh`: ordered deployment workflow
- `proxmox/scripts/`: validates, plans, and applies Proxmox OpenTofu state

## Workflow

Secrets are supplied from environment variables. With direnv, `.envrc` loads
the ignored local `.env` file automatically; use the variable names in
`.env.example`. Run `direnv allow` after changing `.envrc`.

```sh
kubernetes/scripts/apply_secrets.sh
kubernetes/scripts/validate.sh
kubernetes/scripts/deploy.sh
```

Proxmox workflow:

```sh
proxmox/scripts/validate.sh
proxmox/scripts/plan.sh
```

Review the first Proxmox plan before running `proxmox/scripts/apply.sh`.

Traefik is rendered directly with Helm instead of through Kustomize because the
current Kustomize Helm integration calls a Helm v3-only flag and fails with Helm
v4.
