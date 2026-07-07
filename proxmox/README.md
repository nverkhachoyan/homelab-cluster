# Proxmox OpenTofu

This directory manages Proxmox VM lifecycle with the `bpg/proxmox` provider.
It is a brownfield import of the running Proxmox guests and the SDN resources
they need in the `olympus` cluster.

Credentials are intentionally not stored here. With direnv, `.envrc` loads the
ignored repo-local `.env` file automatically. You can also export the variables
in your shell directly; use the variable names in `.env.example`.

State is stored in S3:

- bucket: `proxmox-opentofu-770565632827-us-west-1-an`
- key: `homelab-cluster/proxmox/terraform.tfstate`
- region: `us-west-1`

## File Layout

- `backend.tf`, `providers.tf`, `versions.tf`: OpenTofu backend and provider setup
- `variables.tf`: shared inputs
- `ssh-keys.tf`: cloud-init SSH key shaping
- `sdn.tf`: brownfield Proxmox SDN resources
- `vm-resource.tf`: direct Proxmox VM resources for imported VMs
- `inventory.tf`: merged VM inventory map
- `inventory-*.tf`: grouped VM inventory by role; split these further if a role
  grows too large to scan comfortably

## Refactoring Safely

- OpenTofu concatenates all `*.tf` files in this directory, so file renames and
  inventory splits do not change the resource graph by themselves.
- `local.vms` map keys are part of each VM's state address. Renaming a key
  requires a `moved {}` block from the old
  `proxmox_virtual_environment_vm.vms["key"]` address to the new one and a
  clean plan.
- Pure refactors should keep `tofu plan` free of infrastructure
  add/change/destroy actions. Address-only `moved {}` plans are acceptable for
  state migrations.

## Credential Setup

Set these variables in `.env` or your shell:

- `PROXMOX_VE_API_TOKEN`
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
- `AWS_EC2_METADATA_DISABLED=true`

The AWS access key only needs permission to read/write this state object and
its lock file. A scoped IAM policy can look like this:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "s3:ListBucket",
      "Resource": "arn:aws:s3:::proxmox-opentofu-770565632827-us-west-1-an",
      "Condition": {
        "StringLike": {
          "s3:prefix": "homelab-cluster/proxmox/*"
        }
      }
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:PutObject",
        "s3:DeleteObject"
      ],
      "Resource": "arn:aws:s3:::proxmox-opentofu-770565632827-us-west-1-an/homelab-cluster/proxmox/terraform.tfstate*"
    }
  ]
}
```

The token value format used by the provider is:

```sh
PROXMOX_VE_API_TOKEN="user@realm!token_id=secret"
```

If a 1Password item stores the Proxmox token ID and secret as separate fields,
normalize them into the single `PROXMOX_VE_API_TOKEN` value in `.env`.

Privilege-separated Proxmox API tokens need an ACL of their own. The current
token is granted `PVEAdmin` at `/`:

```sh
pveum acl modify / --roles PVEAdmin --tokens "root@pam!tofu" --propagate 1
```

The `proxmox_endpoint` and default SSH public key values in `variables.tf` are
intentionally committed non-secret defaults.

## Workflow

Install OpenTofu locally first. From the repo root, change into this directory:

```sh
cd proxmox
```

Validate formatting and configuration without touching the remote backend:

```sh
tofu fmt -check -recursive

tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT
TF_DATA_DIR="$tmp_dir" tofu init -backend=false -input=false
TF_DATA_DIR="$tmp_dir" tofu validate
```

Create a plan:

```sh
tofu init -input=false
tofu plan -parallelism=1
```

Only apply after reviewing the first plan carefully:

```sh
tofu apply -parallelism=1
```

## Managed Scope

Managed/imported:

- current SDN VXLAN zone, VNet, and subnet
- running k3s VM
- running appliance VMs imported for Proxmox inventory and drift control

## Roadmap

1. Manage cloud-init snippets without committing secrets.
   - Non-secret scripts can be uploaded with
     `proxmox_virtual_environment_file` and `content_type = "snippets"`.
   - GitHub runner registration tokens must not be committed as static snippets
     because they end up in OpenTofu state. Generate them at boot, fetch them
     from a secret manager, or keep the token-bearing snippet manual.

2. Import low-risk cluster configuration.
   - Storage can be modeled with `proxmox_storage_directory` and
     `proxmox_storage_lvmthin`, then imported by storage ID.
   - The disabled cluster firewall options and `vxlan` security group can be
     modeled and imported, but should stay a separate plan.

3. Leave installer media and guest state explicit.
   - Windows and Netgate installer ISOs are not good first-class download
     targets here because of licensing/source stability.
   - Windows TPM/CD-ROM modeling should remain separate from the no-drift VM
     import because this provider version only supports one `cdrom` block and
     did not import the existing TPM state cleanly.
