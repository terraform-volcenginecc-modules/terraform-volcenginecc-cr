output "registry" {
  description = "Private registry metadata."
  value       = module.cr.registries.application
}

output "repository" {
  description = "Private OCI repository metadata."
  value       = module.cr.repositories.api
}

output "repository_url" {
  description = "Tag-free system-domain image address for Docker and VKE."
  value       = module.cr.repositories.api.repository_url
}

output "repository_trn" {
  description = "Repository TRN for IAM authorization."
  value       = module.cr.repositories.api.repository_trn
}
