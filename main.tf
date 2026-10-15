resource "volcenginecc_cr_registry" "this" {
  for_each = var.registries

  name    = each.value.name
  project = each.value.project
  type    = each.value.type
  endpoint = {
    enabled = each.value.public_endpoint_enabled
  }
  tags = [
    for key, value in each.value.tags : {
      key   = key
      value = value
    }
  ]
}

resource "volcenginecc_cr_name_space" "this" {
  for_each = var.namespaces

  registry = volcenginecc_cr_registry.this[each.value.registry_key].name
  name     = each.value.name
  project  = each.value.project

  lifecycle {
    precondition {
      condition     = contains(keys(var.registries), each.value.registry_key)
      error_message = "Each namespace registry_key must reference a managed registry."
    }
  }
}

resource "volcenginecc_cr_repository" "this" {
  for_each = var.repositories

  registry     = volcenginecc_cr_name_space.this[each.value.namespace_key].registry
  namespace    = volcenginecc_cr_name_space.this[each.value.namespace_key].name
  name         = each.value.name
  description  = each.value.description
  access_level = each.value.access_level

  lifecycle {
    precondition {
      condition     = contains(keys(var.namespaces), each.value.namespace_key)
      error_message = "Each repository namespace_key must reference a managed namespace."
    }
  }
}

resource "volcenginecc_cr_robot_account" "this" {
  for_each = var.robot_accounts

  registry    = volcenginecc_cr_registry.this[each.value.registry_key].name
  username    = each.value.username
  description = each.value.description
  duration    = each.value.duration
  disabled    = each.value.disabled
  random      = each.value.random_password
  password    = each.value.random_password ? null : each.value.password
  permissions = [
    for permission in values(each.value.permissions) : {
      resource = permission.resource
      actions  = permission.actions
    }
  ]

  lifecycle {
    precondition {
      condition     = contains(keys(var.registries), each.value.registry_key)
      error_message = "Each robot account registry_key must reference a managed registry."
    }

    precondition {
      condition     = each.value.random_password || each.value.password != null
      error_message = "robot_accounts password must be set when random_password is false."
    }
  }
}

resource "volcenginecc_cr_vpc_endpoint" "this" {
  for_each = var.vpc_endpoints

  registry = volcenginecc_cr_registry.this[each.value.registry_key].name
  vpcs = [
    for vpc in values(each.value.vpcs) : {
      account_id = vpc.account_id
      subnet_id  = vpc.subnet_id
      vpc_id     = vpc.vpc_id
    }
  ]

  lifecycle {
    precondition {
      condition     = contains(keys(var.registries), each.value.registry_key)
      error_message = "Each VPC endpoint registry_key must reference a managed registry."
    }
  }
}

resource "volcenginecc_cr_endpoint_acl_policy" "this" {
  for_each = var.public_endpoint_acl_policies

  registry    = volcenginecc_cr_registry.this[each.value.registry_key].name
  type        = "Public"
  entry       = each.value.entry
  description = each.value.description

  lifecycle {
    precondition {
      condition     = contains(keys(var.registries), each.value.registry_key)
      error_message = "Each public endpoint ACL policy registry_key must reference a managed registry."
    }

    precondition {
      condition     = var.registries[each.value.registry_key].public_endpoint_enabled
      error_message = "public_endpoint_acl_policies require public_endpoint_enabled for their registry."
    }
  }
}
