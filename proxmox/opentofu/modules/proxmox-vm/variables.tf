variable "vm" {
  type = object({
    node_name = string
    vm_id     = number
    name      = string

    tags                                 = optional(list(string), [])
    template                             = optional(bool, false)
    on_boot                              = optional(bool, false)
    started                              = optional(bool)
    stop_on_destroy                      = optional(bool)
    protection                           = optional(bool)
    purge_on_destroy                     = optional(bool)
    delete_unreferenced_disks_on_destroy = optional(bool)
    bios                                 = optional(string, "seabios")
    machine                              = optional(string)
    scsi_hardware                        = optional(string)
    boot_order                           = optional(list(string))
    startup = optional(object({
      down_delay = optional(number)
      order      = optional(number)
      up_delay   = optional(number)
    }))
    agent = optional(object({
      enabled = optional(bool, true)
      timeout = optional(string)
      trim    = optional(bool)
      type    = optional(string)
      wait_for_ip = optional(object({
        disabled = optional(bool)
        ipv4     = optional(bool)
        ipv6     = optional(bool)
      }))
    }))
    cpu = object({
      cores        = number
      sockets      = optional(number, 1)
      type         = optional(string, "x86-64-v2-AES")
      architecture = optional(string)
      flags        = optional(list(string))
      hotplugged   = optional(number)
      limit        = optional(number)
      numa         = optional(bool)
      units        = optional(number)
    })
    memory = object({
      dedicated      = number
      floating       = optional(number)
      hugepages      = optional(string)
      keep_hugepages = optional(bool)
      shared         = optional(number)
    })
    efi_disk = optional(object({
      datastore_id      = optional(string)
      file_format       = optional(string)
      pre_enrolled_keys = optional(bool)
      type              = optional(string)
    }))
    tpm_state = optional(object({
      datastore_id = optional(string)
      version      = optional(string)
    }))
    disks = list(object({
      interface         = string
      datastore_id      = optional(string)
      aio               = optional(string)
      backup            = optional(bool)
      cache             = optional(string)
      discard           = optional(string)
      file_format       = optional(string)
      file_id           = optional(string)
      import_from       = optional(string)
      iothread          = optional(bool)
      path_in_datastore = optional(string)
      queues            = optional(number)
      replicate         = optional(bool)
      serial            = optional(string)
      size              = optional(number)
      ssd               = optional(bool)
    }))
    cdrom = optional(object({
      enabled   = optional(bool)
      file_id   = optional(string)
      interface = optional(string)
    }))
    network_devices = optional(list(object({
      bridge       = string
      disconnected = optional(bool)
      enabled      = optional(bool)
      firewall     = optional(bool)
      mac_address  = optional(string)
      model        = optional(string, "virtio")
      mtu          = optional(number)
      queues       = optional(number)
      rate_limit   = optional(number)
      trunks       = optional(string)
      vlan_id      = optional(number)
    })), [])
    initialization = optional(object({
      datastore_id         = optional(string)
      file_format          = optional(string)
      interface            = optional(string)
      meta_data_file_id    = optional(string)
      network_data_file_id = optional(string)
      type                 = optional(string)
      upgrade              = optional(bool)
      user_data_file_id    = optional(string)
      vendor_data_file_id  = optional(string)
      ipv4 = optional(object({
        address = string
        gateway = optional(string)
      }))
      ipv6 = optional(object({
        address = string
        gateway = optional(string)
      }))
      dns = optional(object({
        domain  = optional(string)
        servers = optional(list(string))
      }))
      user_account = optional(object({
        username = string
        keys     = optional(list(string), [])
      }))
    }))
    operating_system = optional(object({
      type = optional(string)
    }))
    serial_devices = optional(list(object({
      device = optional(string)
    })), [])
    vga = optional(object({
      clipboard = optional(string)
      memory    = optional(number)
      type      = optional(string)
    }))
  })
}
