# Cluster resource mappings let VMs reference host PCI devices by name. The API
# token can attach mapped devices; raw PCI IDs on a VM require root@pam.
#
# The token needs PVEMappingAdmin on /mapping/pci to manage these:
#   pveum acl modify /mapping/pci --roles PVEMappingAdmin --tokens "root@pam!tofu" --propagate 1
resource "proxmox_hardware_mapping_pci" "igpu" {
  name             = "igpu"
  comment          = "Intel HD Graphics 530 iGPU, split into GVT-g virtual GPUs"
  mediated_devices = true

  # Only zeus has GVT-g enabled (proxmox/ansible gvt_hosts group).
  map = [
    {
      node         = "zeus"
      path         = "0000:00:02.0"
      id           = "8086:1912"
      subsystem_id = "103c:829a"
      iommu_group  = 0
    },
  ]
}
