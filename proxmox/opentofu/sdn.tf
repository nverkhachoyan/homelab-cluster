resource "proxmox_sdn_zone_vxlan" "myzone" {
  id   = "myzone"
  ipam = "pve"
  mtu  = 1450

  peers = [
    "192.168.1.80",
    "192.168.1.81",
    "192.168.1.127",
    "192.168.1.77",
    "192.168.1.146",
  ]
}

resource "proxmox_sdn_vnet" "vxvnet1" {
  id   = "vxvnet1"
  zone = proxmox_sdn_zone_vxlan.myzone.id
  tag  = 100000
}

resource "proxmox_sdn_subnet" "myzone_10_0_0_0_24" {
  cidr    = "10.0.0.0/24"
  gateway = "10.0.0.1"
  snat    = true
  vnet    = proxmox_sdn_vnet.vxvnet1.id
}
