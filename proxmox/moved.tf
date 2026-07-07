moved {
  from = proxmox_sdn_zone_vxlan.myzone
  to   = proxmox_sdn_zone_vxlan.internal_vxlan
}

moved {
  from = proxmox_sdn_vnet.vxvnet1
  to   = proxmox_sdn_vnet.internal_lan
}

moved {
  from = proxmox_sdn_subnet.myzone_10_0_0_0_24
  to   = proxmox_sdn_subnet.internal_lan_10_0_0_0_24
}
