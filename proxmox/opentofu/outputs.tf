output "manual_initially" {
  description = "Existing guests intentionally left outside OpenTofu management."
  value       = local.manual_initially
}

output "cloud_image_file_ids" {
  description = "Managed cloud image file IDs by image name and Proxmox node."
  value = var.enable_managed_media_downloads ? {
    for image_name in keys(local.cloud_images) : image_name => {
      for node_name in local.proxmox_node_names :
      node_name => proxmox_download_file.cloud_images["${image_name}_${node_name}"].id
    }
  } : {}
}
