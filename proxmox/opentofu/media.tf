locals {
  proxmox_node_names = [
    "apollo",
    "athena",
    "hera",
    "poseidon",
    "zeus",
  ]

  cloud_images = {
    ubuntu_2404_minimal_amd64_20260626 = {
      checksum           = "bd9023e71b7bb5bded14e4fb0c998e0d93d7149e9056c3e68b46ff9097dd17d5"
      checksum_algorithm = "sha256"
      content_type       = "import"
      datastore_id       = "local"
      file_name          = "ubuntu-24.04-minimal-cloudimg-amd64-20260626.qcow2"
      url                = "https://cloud-images.ubuntu.com/minimal/releases/noble/release-20260626/ubuntu-24.04-minimal-cloudimg-amd64.img"
    }
  }

  cloud_image_downloads = merge([
    for image_name, image in local.cloud_images : {
      for node_name in local.proxmox_node_names : "${image_name}_${node_name}" => merge(image, {
        image_name = image_name
        node_name  = node_name
      })
    }
  ]...)
}

resource "proxmox_download_file" "cloud_images" {
  for_each = var.enable_managed_media_downloads ? local.cloud_image_downloads : {}

  checksum            = each.value.checksum
  checksum_algorithm  = each.value.checksum_algorithm
  content_type        = each.value.content_type
  datastore_id        = each.value.datastore_id
  file_name           = each.value.file_name
  node_name           = each.value.node_name
  overwrite           = false
  overwrite_unmanaged = false
  url                 = each.value.url
}
