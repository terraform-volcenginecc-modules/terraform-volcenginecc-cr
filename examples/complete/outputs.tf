output "repositories" {
  description = "Private OCI repositories available to CI/CD and VKE."
  value       = module.cr.repositories
}

output "repository_urls" {
  description = "Tag-free system-domain image addresses keyed by repository key."
  value = {
    for key, repository in module.cr.repositories :
    key => repository.repository_url
  }
}

output "repository_trns" {
  description = "Repository TRNs for IAM authorization, keyed by repository key."
  value = {
    for key, repository in module.cr.repositories :
    key => repository.repository_trn
  }
}

output "robot_accounts" {
  description = "CI push and VKE pull robot account metadata. Passwords are not output."
  value       = module.cr.robot_accounts
}

output "vke_private_endpoint" {
  description = "CR private endpoint details for the VKE VPC."
  value       = module.cr.vpc_endpoints.vke
}
