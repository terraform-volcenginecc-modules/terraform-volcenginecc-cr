output "registries" {
  description = "Non-sensitive CR registry metadata keyed by the input registries map key."
  value = {
    for key, registry in volcenginecc_cr_registry.this : key => {
      id                    = registry.id
      name                  = registry.name
      charge_type           = registry.charge_type
      public_endpoint_state = try(registry.endpoint.status, null)
      status                = try(registry.status.phase, null)
      created_time          = registry.created_time
    }
  }
}

output "namespaces" {
  description = "Managed CR namespaces keyed by the input namespaces map key."
  value = {
    for key, namespace in volcenginecc_cr_name_space.this : key => {
      id           = namespace.id
      registry     = namespace.registry
      name         = namespace.name
      project      = namespace.project
      created_time = namespace.created_time
    }
  }
}

output "repositories" {
  description = "Managed CR repositories keyed by the input repositories map key."
  value = {
    for key, repository in volcenginecc_cr_repository.this : key => {
      id           = repository.id
      registry     = repository.registry
      namespace    = repository.namespace
      name         = repository.name
      access_level = repository.access_level
      created_time = repository.create_time
      updated_time = repository.update_time
    }
  }
}

output "robot_accounts" {
  description = "Robot account metadata keyed by input key. Passwords are intentionally never output."
  value = {
    for key, account in volcenginecc_cr_robot_account.this : key => {
      id         = account.id
      registry   = account.registry
      username   = account.username
      disabled   = account.disabled
      expires_at = account.expires_at
      created_at = account.create_time
      updated_at = account.update_time
    }
  }
}

output "vpc_endpoints" {
  description = "Managed CR private endpoint details keyed by input key, including cloud-returned private IP addresses."
  value = {
    for key, endpoint in volcenginecc_cr_vpc_endpoint.this : key => {
      id       = endpoint.id
      registry = endpoint.registry
      vpcs     = endpoint.vpcs
    }
  }
}
