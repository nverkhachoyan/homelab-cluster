provider "proxmox" {
  endpoint = var.proxmox_endpoint
  insecure = var.proxmox_insecure

  ssh {
    username = var.proxmox_ssh_username
    agent    = var.proxmox_ssh_agent
  }
}
