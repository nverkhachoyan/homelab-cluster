# qBittorrent + Proton VPN

qBittorrent runs in the same Pod as a Gluetun sidecar. Gluetun owns the Pod network namespace, establishes a Proton VPN WireGuard tunnel, and enables Proton VPN port forwarding. qBittorrent waits for the `tun0` interface before starting.

## Required Secret

Create this Secret before deploying qBittorrent:

```sh
kubectl -n media create secret generic protonvpn-secrets \
  --from-literal=wireguard_private_key='<PROTON_WIREGUARD_PRIVATE_KEY>'
```

Get the value from a Proton VPN WireGuard config. Copy the `PrivateKey` value only; do not commit it to Git.

## Network behavior

- qBittorrent Web UI listens on port `8080`.
- The Kubernetes Service only exposes the Web UI port inside the cluster.
- BitTorrent TCP/UDP ports are no longer exposed through a home-network LoadBalancer Service.
- Proton VPN assigns a forwarded port dynamically; Gluetun updates qBittorrent through its local Web API when the port is ready.
- If the VPN tunnel is down, Gluetun's firewall should prevent qBittorrent from falling back to the home ISP connection.

## Verification after deploy

```sh
kubectl -n media rollout status deployment/qbittorrent --timeout=300s
kubectl -n media logs deployment/qbittorrent -c gluetun | grep -iE 'vpn|wireguard|forwarded|port forwarding'
kubectl -n media exec deployment/qbittorrent -c gluetun -- wget -qO- https://ipinfo.io/ip
```

The public IP should be a Proton VPN exit IP, not the home ISP IP.

## Follow-up hardening

qBittorrent is an admin surface. Prefer Tailscale-only access or Cloudflare Access protection over a public unauthenticated hostname.
