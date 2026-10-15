# terraform-volcenginecc-cr

Terraform module for Volcengine Container Registry (CR) registries, namespaces, private OCI repositories, robot accounts, VPC endpoints, and explicit public endpoint CIDR allowlists.

## 1. Overview

The module owns the CR resources declared in its input maps. The caller owns provider authentication, region configuration, IAM users and roles, VKE clusters, VPCs, subnets, image build and push operations, and Kubernetes image-pull Secrets.

Registry name, project, type, and tags; all namespace identity fields; repository identity fields; robot-account registry and username; VPC-endpoint registry; and public allowlist entries are create-only in the current Provider schema. Keep map keys stable because changing a key changes the Terraform address.

## 2. Usage

### 2.1 Basic Usage

```hcl
module "cr" {
  source  = "terraform-volcenginecc-modules/cr/volcenginecc"
  version = "~> 1.0"

  registries = {
    app = {
      name = "example-cr"
    }
  }

  namespaces = {
    team = {
      registry_key = "app"
      name         = "team"
    }
  }

  repositories = {
    api = {
      namespace_key = "team"
      name          = "api"
    }
  }
}
```

## 3. Examples

- `basic` describes a private registry, namespace, and repository.
- `complete` describes CI push permissions, a VKE private pull endpoint, optional public CIDR allowlisting, and separate pull-only credentials.

## 4. Requirements

| Name | Version |
|---|---|
| Terraform | `>= 1.5.0` |
| VolcengineCC Provider | `>= 0.0.70` |

## 5. Providers

| Name | Source |
|---|---|
| `volcenginecc` | `volcengine/volcenginecc` |

## 6. Resources

| Name | Purpose |
|---|---|
| `volcenginecc_cr_registry` | CR registry instance |
| `volcenginecc_cr_name_space` | Registry namespace |
| `volcenginecc_cr_repository` | Private or public OCI repository |
| `volcenginecc_cr_robot_account` | Scoped CI/CD or VKE robot credentials |
| `volcenginecc_cr_vpc_endpoint` | Private VPC image-pull endpoint |
| `volcenginecc_cr_endpoint_acl_policy` | Explicit public endpoint CIDR allowlist |

## 7. Inputs

| Name | Type | Default | Description |
|---|---|---|---|
| `registries` | `map(object)` | required | Stable-keyed CR registries; public endpoint is disabled by default. |
| `namespaces` | `map(object)` | `{}` | Stable-keyed namespaces referencing a managed registry. |
| `repositories` | `map(object)` | `{}` | Stable-keyed repositories referencing a managed namespace; defaults to `Private`. |
| `robot_accounts` | `map(object)` | `{}` | Scoped robot accounts with CreateRepository, PullRepository, and/or PushRepository permissions. |
| `vpc_endpoints` | `map(object)` | `{}` | Private endpoints referencing caller-owned VPCs and subnets. |
| `public_endpoint_acl_policies` | `map(object)` | `{}` | Opt-in public endpoint CIDRs; `0.0.0.0/0` is rejected. |

## 8. Outputs

| Name | Description |
|---|---|
| `registries` | Registry IDs, names, status, and public-endpoint state keyed by input key. |
| `namespaces` | Namespace metadata keyed by input key. |
| `repositories` | Repository metadata keyed by input key. |
| `robot_accounts` | Robot account metadata without passwords, keyed by input key. |
| `vpc_endpoints` | Private endpoint details and cloud-returned VPC addresses keyed by input key. |

## 9. Notes

- Provider schema exposes no CR image-retention-policy resource, image scanning setting, CR IAM user/role authorization resource, `force_delete` setting, or repository URL/ARN output. This module does not pretend to manage those capabilities.
- A robot account is the supported Provider-managed push/pull identity. A supplied or generated password is not returned, but the current Provider does not mark it sensitive and can retain it in State; use an encrypted remote backend, do not put it in source files, and rotate it through an approved secret workflow.
- The VKE integration creates a CR VPC endpoint only. Configure the resulting registry endpoint and robot credential in the VKE workload's image-pull Secret outside this module.
- Enable the public endpoint only when necessary and use narrowly scoped CIDRs. Private repositories, private endpoints, and pull-only VKE accounts are the default posture.
- Import existing resources before declaring them, using Provider identifiers: registry `name`, namespace `registry|name`, repository `registry|namespace|name`, and robot account `registry|username`.
- Real-cloud validation evidence is recorded in `examples/TEST_REPORT.md`. Both basic and complete completed apply, a second `terraform plan` with `No changes`, destroy, and absence checks. Complete uses the CR OpenAPI-documented `permissions.resource = "*"` form: CI has pull/push actions and VKE has pull-only access. This form is registry-wide; use a narrower documented resource identifier when CR publishes one.
