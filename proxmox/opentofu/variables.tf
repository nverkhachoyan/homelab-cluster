variable "proxmox_endpoint" {
  description = "Proxmox API endpoint. Credentials are provided by PROXMOX_VE_API_TOKEN."
  type        = string
  default     = "https://zeus.alligator-rainbow.ts.net:8006/"
}

variable "proxmox_insecure" {
  description = "Allow the self-signed Proxmox API certificate."
  type        = bool
  default     = true
}

variable "proxmox_ssh_username" {
  description = "SSH username used by provider operations that need node file access."
  type        = string
  default     = "root"
}

variable "proxmox_ssh_agent" {
  description = "Use the local SSH agent for provider SSH operations."
  type        = bool
  default     = true
}

variable "default_ssh_public_key" {
  description = "Default cloud-init SSH public key for Linux VMs."
  type        = string
  default     = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBoVotkT+jNCRAtiZM+tQSh/grcNL17yldLsy1OhnsSb nverkhachoyan@iloveyou-2.local"
}

variable "enable_managed_media_downloads" {
  description = "Enable creation of managed Proxmox download-file resources. Requires the Proxmox API token to have the download-url privileges documented in README.md."
  type        = bool
  default     = false
}
