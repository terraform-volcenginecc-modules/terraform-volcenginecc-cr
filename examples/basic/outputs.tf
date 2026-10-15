output "registry" {
  description = "Private registry metadata."
  value       = module.cr.registries.application
}

output "repository" {
  description = "Private OCI repository metadata."
  value       = module.cr.repositories.api
}
