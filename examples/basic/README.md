# Basic CR example

Creates one private CR registry, namespace, and OCI repository.

## 1. Overview

This example represents the minimum private image repository foundation for an application team.

## 2. Usage

Set `region`, `registry_name`, and `namespace_name` through a protected variable source, then run `terraform init`, `terraform plan`, and `terraform apply`.

## 3. Examples

This is the `basic` scenario: private registry, namespace, and repository.

## 4. Requirements

Terraform `>= 1.5.0` and `volcengine/volcenginecc >= 0.0.70`.

## 5. Providers

`volcenginecc` is configured with the caller-provided region and external credentials.

## 6. Resources

The published CR module creates a registry, namespace, and private repository.

## 7. Inputs

`region`, `registry_name`, and `namespace_name` are required. `repository_name` defaults to `api`; `project` defaults to `default`.

## 8. Outputs

`registry` and `repository` return non-sensitive CR metadata.

## 9. Notes

The example does not create IAM identities, VPC resources, VKE clusters, image-pull Secrets, or retention policies. Confirm the second plan has no changes after apply.
