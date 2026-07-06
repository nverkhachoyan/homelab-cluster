terraform {
  backend "s3" {
    bucket       = "proxmox-opentofu-770565632827-us-west-1-an"
    key          = "homelab-cluster/proxmox/terraform.tfstate"
    region       = "us-west-1"
    encrypt      = true
    use_lockfile = true
  }
}
