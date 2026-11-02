# Complete CR example

Creates private application repositories, a CI push robot account, a pull-only VKE robot account, and a CR private endpoint in a caller-owned VKE VPC.

## 1. Overview

This example models CI/CD image pushes and VKE private image pulls while keeping repositories private.

## 2. Usage

Provide the CR names and caller-owned VKE VPC/subnet values through a protected variable source, then run `terraform init`, `terraform plan`, and `terraform apply`.

## 3. Examples

This is the `complete` scenario: private repositories, CI push permission, VKE pull permission, and private endpoint access.

## 4. Requirements

Terraform `>= 1.5.0` and `volcengine/volcenginecc >= 0.0.70`.

## 5. Providers

`volcenginecc` is configured with the caller-provided region and external credentials.

## 6. Resources

The published CR module creates the CR hierarchy, two namespace-scoped robot accounts, and a CR VPC endpoint. A public CIDR allowlist is created only after explicit endpoint opt-in.

## 7. Inputs

Registry and robot-account names plus VKE VPC/subnet/account values are required. `account_id` must own both the CR registry, for repository TRN construction, and the VKE VPC used by this example. The public endpoint is disabled by default; set a non-global CI CIDR only when enabling it.

## 8. Outputs

`repositories`, `repository_urls`, `repository_trns`, `robot_accounts`, and `vke_private_endpoint` return non-sensitive metadata. Repository URLs are tag-free system-domain addresses; robot passwords are never output.

## 9. Notes

The VKE cluster and its image-pull Secret remain caller-owned. Both robot accounts use `var.namespace_name` as their permission resource: CI can pull and push; VKE can only pull. The Provider does not expose CR retention policies or CR IAM user/role grants. Confirm the second plan has no changes after apply, then validate actual CI push, VKE pull, and destroy cleanup in an authorized disposable environment.
