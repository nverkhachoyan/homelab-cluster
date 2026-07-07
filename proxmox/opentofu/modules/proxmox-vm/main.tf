# Brownfield VMs should never be deleted by OpenTofu. In-place changes are still
# possible, so plan output must be reviewed before applying.
resource "proxmox_virtual_environment_vm" "this" {
  name      = var.vm.name
  node_name = var.vm.node_name
  vm_id     = var.vm.vm_id
  tags      = var.vm.tags
  template  = var.vm.template
  on_boot   = var.vm.on_boot
  started   = var.vm.started

  delete_unreferenced_disks_on_destroy = var.vm.delete_unreferenced_disks_on_destroy
  protection                           = var.vm.protection
  purge_on_destroy                     = var.vm.purge_on_destroy
  stop_on_destroy                      = var.vm.stop_on_destroy

  bios          = var.vm.bios
  machine       = var.vm.machine
  scsi_hardware = var.vm.scsi_hardware
  boot_order    = var.vm.boot_order

  dynamic "startup" {
    for_each = var.vm.startup == null ? [] : [var.vm.startup]

    content {
      down_delay = startup.value.down_delay
      order      = startup.value.order
      up_delay   = startup.value.up_delay
    }
  }

  dynamic "agent" {
    for_each = var.vm.agent == null ? [] : [var.vm.agent]

    content {
      enabled = agent.value.enabled
      timeout = agent.value.timeout
      trim    = agent.value.trim
      type    = agent.value.type

      dynamic "wait_for_ip" {
        for_each = agent.value.wait_for_ip == null ? [] : [agent.value.wait_for_ip]

        content {
          disabled = wait_for_ip.value.disabled
          ipv4     = wait_for_ip.value.ipv4
          ipv6     = wait_for_ip.value.ipv6
        }
      }
    }
  }

  cpu {
    architecture = var.vm.cpu.architecture
    cores        = var.vm.cpu.cores
    flags        = var.vm.cpu.flags
    hotplugged   = var.vm.cpu.hotplugged
    limit        = var.vm.cpu.limit
    numa         = var.vm.cpu.numa
    sockets      = var.vm.cpu.sockets
    type         = var.vm.cpu.type
    units        = var.vm.cpu.units
  }

  memory {
    dedicated      = var.vm.memory.dedicated
    floating       = var.vm.memory.floating
    hugepages      = var.vm.memory.hugepages
    keep_hugepages = var.vm.memory.keep_hugepages
    shared         = var.vm.memory.shared
  }

  dynamic "efi_disk" {
    for_each = var.vm.efi_disk == null ? [] : [var.vm.efi_disk]

    content {
      datastore_id      = efi_disk.value.datastore_id
      file_format       = efi_disk.value.file_format
      pre_enrolled_keys = efi_disk.value.pre_enrolled_keys
      type              = efi_disk.value.type
    }
  }

  dynamic "tpm_state" {
    for_each = var.vm.tpm_state == null ? [] : [var.vm.tpm_state]

    content {
      datastore_id = tpm_state.value.datastore_id
      version      = tpm_state.value.version
    }
  }

  dynamic "disk" {
    for_each = var.vm.disks

    content {
      aio               = disk.value.aio
      backup            = disk.value.backup
      cache             = disk.value.cache
      datastore_id      = disk.value.datastore_id
      discard           = disk.value.discard
      file_format       = disk.value.file_format
      file_id           = disk.value.file_id
      import_from       = disk.value.import_from
      interface         = disk.value.interface
      iothread          = disk.value.iothread
      path_in_datastore = disk.value.path_in_datastore
      queues            = disk.value.queues
      replicate         = disk.value.replicate
      serial            = disk.value.serial
      size              = disk.value.size
      ssd               = disk.value.ssd
    }
  }

  dynamic "cdrom" {
    for_each = var.vm.cdrom == null ? [] : [var.vm.cdrom]

    content {
      # Provider deprecated cdrom.enabled; "none" represents an empty drive.
      file_id = cdrom.value.enabled == false || (
        cdrom.value.enabled == null && cdrom.value.file_id == null
      ) ? "none" : cdrom.value.file_id
      interface = cdrom.value.interface
    }
  }

  network_device = [
    for device in var.vm.network_devices : {
      bridge       = device.bridge
      disconnected = device.disconnected
      enabled      = device.enabled
      firewall     = device.firewall
      mac_address  = device.mac_address
      model        = device.model
      mtu          = device.mtu
      queues       = device.queues
      rate_limit   = device.rate_limit
      trunks       = device.trunks
      vlan_id      = device.vlan_id
    }
  ]

  dynamic "initialization" {
    for_each = var.vm.initialization == null ? [] : [var.vm.initialization]

    content {
      datastore_id         = initialization.value.datastore_id
      file_format          = initialization.value.file_format
      interface            = initialization.value.interface
      meta_data_file_id    = initialization.value.meta_data_file_id
      network_data_file_id = initialization.value.network_data_file_id
      type                 = initialization.value.type
      upgrade              = initialization.value.upgrade
      user_data_file_id    = initialization.value.user_data_file_id
      vendor_data_file_id  = initialization.value.vendor_data_file_id

      dynamic "dns" {
        for_each = initialization.value.dns == null ? [] : [initialization.value.dns]

        content {
          domain  = dns.value.domain
          servers = dns.value.servers
        }
      }

      dynamic "ip_config" {
        for_each = initialization.value.ipv4 == null && initialization.value.ipv6 == null ? [] : [initialization.value]

        content {
          dynamic "ipv4" {
            for_each = ip_config.value.ipv4 == null ? [] : [ip_config.value.ipv4]

            content {
              address = ipv4.value.address
              gateway = ipv4.value.gateway
            }
          }

          dynamic "ipv6" {
            for_each = ip_config.value.ipv6 == null ? [] : [ip_config.value.ipv6]

            content {
              address = ipv6.value.address
              gateway = ipv6.value.gateway
            }
          }
        }
      }

      dynamic "user_account" {
        for_each = initialization.value.user_account == null ? [] : [initialization.value.user_account]

        content {
          username = user_account.value.username
          keys     = user_account.value.keys
        }
      }
    }
  }

  dynamic "operating_system" {
    for_each = var.vm.operating_system == null ? [] : [var.vm.operating_system]

    content {
      type = operating_system.value.type
    }
  }

  dynamic "serial_device" {
    for_each = var.vm.serial_devices

    content {
      device = serial_device.value.device
    }
  }

  dynamic "vga" {
    for_each = var.vm.vga == null ? [] : [var.vm.vga]

    content {
      clipboard = vga.value.clipboard
      memory    = vga.value.memory
      type      = vga.value.type
    }
  }

  lifecycle {
    ignore_changes = [
      # VM 9000 is a template with a base-* boot disk. The bpg/proxmox provider
      # only resizes vm-* disks it considers VM-owned, so this stays ignored
      # until template base disks can be modeled separately.
      disk[0].size,
      reboot,
      started,
      initialization[0].user_account[0].password,
    ]
  }
}
