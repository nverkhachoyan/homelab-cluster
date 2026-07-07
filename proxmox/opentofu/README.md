# Proxmox OpenTofu

This directory manages Proxmox VM lifecycle with the `bpg/proxmox` provider.
It starts as a brownfield import of the Linux/cloud-init guests and templates
already running in the `olympus` cluster.

Credentials are intentionally not stored here. With direnv, `.envrc` loads the
ignored repo-local `.env` file automatically. You can also export the variables
in your shell directly; use the variable names in `.env.example`.

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
normalize them into the single `PROXMOX_VE_API_TOKEN` value in `.env`. The
scripts do not assemble credentials at runtime.

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

## First-Pass Scope

Managed/imported first:

- current SDN VXLAN zone, VNet, and subnet
- k3s VMs
- Linux utility VMs
- appliance VMs imported for Proxmox inventory and drift control
- GitHub Actions runner templates
- Ubuntu cloud-init templates

## Roadmap

1. Manage reusable media.
   - Use `proxmox_download_file` for cloud images because it downloads directly
     from the Proxmox node and replaces the deprecated
     `proxmox_virtual_environment_download_file` resource.
   - Media downloads are enabled by default. Set
     `enable_managed_media_downloads = false` only while debugging Proxmox
     download-url permissions.
   - Store VM disk images as `content_type = "import"` on `local`; this storage
     already has the Proxmox `Import` content type enabled.
   - Create downloads per node. The `local` datastore is marked shared, but the
     actual files differ by node, so a single cluster-wide media resource would
     hide drift.
   - Pin release URLs and checksums. Avoid mutable `current/` URLs for baseline
     images unless intentionally testing an image refresh.
   - The Proxmox download-url API requires `Datastore.AllocateTemplate`,
     `Sys.Audit`, and `Sys.Modify`. `PVEAdmin` already covers the datastore
     and audit privileges, and `permissions.tf` grants the existing
     `root@pam!tofu` token the narrow `OpenTofuDownload` role for `Sys.Modify`.

2. Rebuild templates from managed media.
   - Keep current templates imported until replacement templates have been
     created and boot-tested.
   - New Linux templates should import from the managed cloud image file for
     their node, then use cloud-init for first-boot customization.
   - Replace consumers node-by-node after a clean plan, not by mutating all
     templates and guests at once.

3. Manage cloud-init snippets without committing secrets.
   - Non-secret scripts can be uploaded with
     `proxmox_virtual_environment_file` and `content_type = "snippets"`.
   - GitHub runner registration tokens must not be committed as static snippets
     because they end up in OpenTofu state. Generate them at boot, fetch them
     from a secret manager, or keep the token-bearing snippet manual.

4. Import low-risk cluster configuration.
   - Storage can be modeled with `proxmox_storage_directory` and
     `proxmox_storage_lvmthin`, then imported by storage ID.
   - The disabled cluster firewall options and `vxlan` security group can be
     modeled and imported, but should stay a separate plan from media/template
     work.
   - The additional `root@pam!tofu` download ACL is modeled with `proxmox_acl`;
     the token secret itself remains bootstrap/1Password-owned.

5. Leave installer media and guest state explicit.
   - Windows and Netgate installer ISOs are not good first-class download
     targets here because of licensing/source stability.
   - Windows TPM/CD-ROM modeling should remain separate from the no-drift VM
     import because this provider version only supports one `cdrom` block and
     did not import the existing TPM state cleanly.
