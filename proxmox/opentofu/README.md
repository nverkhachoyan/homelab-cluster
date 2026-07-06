# Proxmox OpenTofu

This directory manages Proxmox VM lifecycle with the `bpg/proxmox` provider.
It starts as a brownfield import of the Linux/cloud-init guests and templates
already running in the `olympus` cluster.

Credentials are intentionally not stored here. The helper scripts read
`PROXMOX_VE_API_TOKEN` and AWS credentials directly, or build them from
1Password fields.

State is stored in S3:

- bucket: `proxmox-opentofu-770565632827-us-west-1-an`
- key: `homelab-cluster/proxmox/terraform.tfstate`
- region: `us-west-1`

## File Layout

- `backend.tf`, `providers.tf`, `versions.tf`: OpenTofu backend and provider setup
- `sdn.tf`: brownfield Proxmox SDN resources
- `vms.tf`: stable module call for imported VMs
- `vms-*.tf`: grouped VM inventory by role
- `modules/proxmox-vm/`: reusable VM shape with brownfield lifecycle guards

## Credential Setup

Add these fields to the `homelab-secrets` 1Password item:

- `proxmox_api_token_id`
- `proxmox_api_token_secret`
- `aws_s3_backend_access_key_id`
- `aws_s3_backend_secret_access_key`

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

You can also export `PROXMOX_VE_API_TOKEN` and
`AWS_ACCESS_KEY_ID`/`AWS_SECRET_ACCESS_KEY` yourself and skip 1Password.

Privilege-separated Proxmox API tokens need an ACL of their own. The current
token is granted `PVEAdmin` at `/`:

```sh
pveum acl modify / --roles PVEAdmin --tokens "root@pam!tofu" --propagate 1
```

## Workflow

```sh
proxmox/scripts/validate.sh
proxmox/scripts/plan.sh
```

Only run `proxmox/scripts/apply.sh` after reviewing the first plan carefully.
Imported brownfield resources are protected with `prevent_destroy`, but a plan
can still propose in-place changes if the imported state differs from the HCL.

## One-Time Bootstrap

These are only needed when standing up this repository from local state or
adopting resources into an empty remote state:

```sh
proxmox/scripts/migrate-state.sh
proxmox/scripts/import.sh
```

`proxmox/scripts/migrate-state.sh` copies an existing local state file to the
configured S3 backend. `proxmox/scripts/import.sh` imports the brownfield
resources listed in the script and skips any addresses already in state.

## First-Pass Scope

Managed/imported first:

- current SDN VXLAN zone, VNet, and subnet
- k3s VMs
- Linux utility VMs
- GitHub Actions runner VMs/templates
- Ubuntu cloud-init templates

Left manual initially:

- `pfsense` because it is the gateway appliance
- `home-assistant` because the important state lives inside the guest
- `win11` because installer ISO, TPM, and guest-local state are not worth
  modeling in the first pass
