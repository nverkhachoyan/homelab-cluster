# qBittorrent + Proton VPN

qBittorrent runs in the same Pod as a Gluetun sidecar. Gluetun owns the Pod network namespace, establishes a Proton VPN WireGuard tunnel, and enables Proton VPN port forwarding. qBittorrent waits for the `tun0` interface before starting.

## Required Secrets

Run the repository secret script before deploying:

```sh
kubernetes/scripts/apply_secrets.sh
```

It reads environment variables loaded by direnv or the current shell and creates:

- `cloudflared/homelab-secrets`
- `media/protonvpn-secrets`
- `media/qbittorrent-webui-secrets`

Required environment variables:

- `CLOUDFLARE_TUNNEL_TOKEN`
- `PROTONVPN_WIREGUARD_PRIVATE_KEY`
- `QBITTORRENT_WEBUI_USERNAME`
- `QBITTORRENT_WEBUI_PASSWORD`

To create the qBittorrent secrets manually instead, use:

```sh
kubectl -n media create secret generic protonvpn-secrets \
  --from-literal=wireguard_private_key='<PROTON_WIREGUARD_PRIVATE_KEY>'
```

Get the value from a Proton VPN WireGuard config. Copy the `PrivateKey` value only; do not commit it to Git.

Create a qBittorrent Web UI credential Secret for Gluetun's port-forwarding callback. Use the same credentials that Radarr/Sonarr/Readarr use for qBittorrent:

```sh
kubectl -n media create secret generic qbittorrent-webui-secrets \
  --from-literal=username='<QBITTORRENT_WEBUI_USERNAME>' \
  --from-literal=password='<QBITTORRENT_WEBUI_PASSWORD>'
```

qBittorrent has one Web UI user, so this is not a separate human account. It is the credential Gluetun uses to log in to the local qBittorrent API.

## Network behavior

- qBittorrent Web UI listens on port `8080`.
- The Kubernetes Service only exposes the Web UI port inside the cluster.
- BitTorrent TCP/UDP ports are no longer exposed through a home-network LoadBalancer Service.
- Proton VPN assigns a forwarded port dynamically; Gluetun writes it to `/tmp/gluetun/forwarded_port` inside the Pod.
- Gluetun authenticates to qBittorrent with `qbittorrent-webui-secrets` and updates qBittorrent's listening port when Proton changes the forwarded port.
- If the VPN tunnel is down, Gluetun's firewall should prevent qBittorrent from falling back to the home ISP connection.

## Verification after deploy

```sh
kubectl -n media rollout status deployment/qbittorrent --timeout=300s
kubectl -n media logs deployment/qbittorrent -c gluetun | grep -iE 'vpn|wireguard|forwarded|port forwarding'
POD="$(kubectl -n media get pod -l app=qbittorrent -o jsonpath='{.items[0].metadata.name}')"
kubectl -n media exec "$POD" -c gluetun -- sh -c 'wget -qO- https://ipinfo.io/ip; echo'
kubectl -n media exec "$POD" -c qbittorrent -- sh -c 'wget -qO- https://ipinfo.io/ip; echo'
kubectl -n media exec "$POD" -c gluetun -- sh -c 'cat /tmp/gluetun/forwarded_port 2>/dev/null || true; echo'
kubectl -n media logs "$POD" -c gluetun | grep -iE 'port forwarding|setPreferences|Forbidden'
```

Both containers should report the same Proton VPN exit IP, not the home ISP IP.
The Gluetun logs should show a forwarded port without `403 Forbidden` from qBittorrent.

## Follow-up hardening

qBittorrent is an admin surface. Prefer Tailscale-only access or Cloudflare Access protection over a public unauthenticated hostname.
