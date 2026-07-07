locals {
  # The runner template needs the SSH key without its trailing comment; other
  # VMs keep the full public key comment.
  default_ssh_keys              = [regex("^\\S+\\s+\\S+", var.default_ssh_public_key)]
  default_ssh_keys_with_comment = [var.default_ssh_public_key]
}
