# Changelog

## Unreleased

- Add tag-free system-domain repository URLs and IAM repository TRNs, derived from the configured CR region, owning account ID, registry, namespace, and repository name.
- Reject empty VPC and subnet IDs, reject fractional robot-account durations, and allow consecutive supported repository separators.
- Make repository and robot-account update timestamps opt-in outputs, and reject null, empty, or whitespace-only manually supplied robot passwords.
- Add the CR module for registries, namespaces, repositories, robot accounts, VPC endpoints, and public endpoint CIDR allowlists.
- Add basic and complete examples plus a Chinese real-cloud validation report.
- Document unsupported Provider capabilities: image retention policies, image scanning, IAM user or role grants, `force_delete`, and repository URL/ARN outputs.
- Validate basic and complete create, no-change plan, destroy, and post-destroy absence checks with Provider v0.0.71.
