resource "proxmox_virtual_environment_role" "opentofu_download" {
  role_id = "OpenTofuDownload"

  privileges = [
    "Sys.Modify",
  ]
}

resource "proxmox_acl" "tofu_download" {
  path      = "/"
  propagate = true
  role_id   = proxmox_virtual_environment_role.opentofu_download.role_id
  token_id  = var.download_token_id
}
