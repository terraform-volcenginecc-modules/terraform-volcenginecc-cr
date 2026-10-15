output "repositories" {
  description = "Private OCI repositories available to CI/CD and VKE."
  value       = module.cr.repositories
}

output "robot_accounts" {
  description = "CI push and VKE pull robot account metadata. Passwords are not output."
  value       = module.cr.robot_accounts
}

output "vke_private_endpoint" {
  description = "CR private endpoint details for the VKE VPC."
  value       = module.cr.vpc_endpoints.vke
}
