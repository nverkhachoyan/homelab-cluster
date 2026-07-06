variable "node_name" {
  type = string
}

variable "vm_id" {
  type = number
}

variable "name" {
  type = string
}

variable "tags" {
  type    = list(string)
  default = []
}

variable "template" {
  type    = bool
  default = false
}

variable "on_boot" {
  type    = bool
  default = false
}

variable "bios" {
  type    = string
  default = "seabios"
}

variable "machine" {
  type    = string
  default = null
}

variable "scsi_hardware" {
  type    = string
  default = null
}

variable "boot_order" {
  type    = list(string)
  default = null
}

variable "agent" {
  type = object({
    enabled = optional(bool, true)
    timeout = optional(string)
    trim    = optional(bool)
    type    = optional(string)
    wait_for_ip = optional(object({
      disabled = optional(bool)
      ipv4     = optional(bool)
      ipv6     = optional(bool)
    }))
  })
  default = null
}

variable "cpu" {
  type = object({
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
}

variable "memory" {
  type = object({
    dedicated      = number
    floating       = optional(number)
    hugepages      = optional(string)
    keep_hugepages = optional(bool)
    shared         = optional(number)
  })
}

variable "efi_disk" {
  type = object({
    datastore_id      = optional(string)
    file_format       = optional(string)
    pre_enrolled_keys = optional(bool)
    type              = optional(string)
  })
  default = null
}

variable "disks" {
  type = list(object({
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
}

variable "network_devices" {
  type = list(object({
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
  }))
  default = []
}

variable "initialization" {
  type = object({
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
  })
  default = null
}

variable "operating_system" {
  type = object({
    type = optional(string)
  })
  default = null
}

variable "serial_devices" {
  type = list(object({
    device = optional(string)
  }))
  default = []
}

variable "vga" {
  type = object({
    clipboard = optional(string)
    memory    = optional(number)
    type      = optional(string)
  })
  default = null
}
