variable "registries" {
  type = map(object({
    name                    = string
    project                 = optional(string, null)
    type                    = optional(string, "Enterprise")
    public_endpoint_enabled = optional(bool, false)
    tags                    = optional(map(string), {})
  }))
  description = "CR registries keyed by stable logical names. Changing a key changes the Terraform address; name, project, type, and tags are create-only in the current Provider schema."

  validation {
    condition = alltrue([
      for registry in values(var.registries) :
      can(regex("^[a-z][a-z0-9-]{1,28}[a-z0-9]$", registry.name)) &&
      contains(["Enterprise", "Micro"], registry.type) &&
      alltrue([for key in keys(registry.tags) : length(trimspace(key)) > 0])
    ])
    error_message = "Registry names must be 3-30 lowercase letters, digits, or hyphens, begin with a letter, end with a letter or digit; type must be Enterprise or Micro; tag keys cannot be empty."
  }
}

variable "namespaces" {
  type = map(object({
    registry_key = string
    name         = string
    project      = optional(string, "default")
  }))
  description = "CR namespaces keyed by stable logical names. registry_key selects a registry managed by this module; all namespace attributes are create-only."
  default     = {}

  validation {
    condition = alltrue([
      for namespace in values(var.namespaces) :
      can(regex("^[a-z0-9]+([._-][a-z0-9]+)*$", namespace.name)) &&
      length(namespace.name) >= 2 && length(namespace.name) <= 90
    ])
    error_message = "Each namespace must have a 2-90 character lowercase name with no leading, trailing, or repeated punctuation."
  }
}

variable "repositories" {
  type = map(object({
    namespace_key = string
    name          = string
    description   = optional(string, null)
    access_level  = optional(string, "Private")
  }))
  description = "OCI repositories keyed by stable logical names. namespace_key selects a managed namespace. Repositories are private by default; identity fields are create-only."
  default     = {}

  validation {
    condition = alltrue([
      for repository in values(var.repositories) :
      can(regex("^[a-z0-9]+([./-]+[a-z0-9]+|_{1,2}[a-z0-9]+)*$", repository.name)) &&
      length(repository.name) <= 128 &&
      contains(["Private", "Public"], repository.access_level) &&
      try(repository.description == null || length(repository.description) <= 300, true)
    ])
    error_message = "Each repository must use a supported 1-128 character lowercase name; consecutive '.', '/', and '-' separators are allowed; access_level must be Private or Public; description must be at most 300 characters."
  }
}

variable "include_update_timestamps" {
  type        = bool
  description = "Whether to include provider-returned repository and robot-account update timestamps in module outputs. Defaults to false to avoid exposing fields that can cause downstream output drift."
  default     = false
}

variable "robot_accounts" {
  type = map(object({
    registry_key    = string
    username        = string
    description     = optional(string, null)
    duration        = optional(number, -1)
    disabled        = optional(bool, false)
    random_password = optional(bool, true)
    password        = optional(string, null)
    permissions = map(object({
      resource = string
      actions  = set(string)
    }))
  }))
  description = "CR robot accounts keyed by stable logical names. Use a scoped namespace resource and only the actions required by CI/CD or VKE. password is sensitive and required only when random_password is false; no password is output."
  default     = {}

  validation {
    condition = alltrue([
      for account in values(var.robot_accounts) :
      can(regex("^crrobot@.+$", account.username)) &&
      account.duration == floor(account.duration) &&
      (account.duration == -1 || (account.duration >= 1 && account.duration <= 366)) &&
      length(account.permissions) > 0 &&
      alltrue([
        for permission in values(account.permissions) :
        length(trimspace(permission.resource)) > 0 &&
        length(permission.actions) > 0 &&
        alltrue([for action in permission.actions : contains(["CreateRepository", "PullRepository", "PushRepository"], action)])
      ])
    ])
    error_message = "Robot accounts must use a crrobot@ username, have integer duration -1 or 1-366, and grant one or more supported actions on non-empty resources."
  }
}

variable "vpc_endpoints" {
  type = map(object({
    registry_key = string
    vpcs = map(object({
      vpc_id     = string
      subnet_id  = string
      account_id = optional(number, null)
    }))
  }))
  description = "Private CR VPC endpoints keyed by stable logical names. Supply caller-owned VPC and subnet IDs, such as the VKE cluster VPC, for private image pulls."
  default     = {}

  validation {
    condition = alltrue([
      for endpoint in values(var.vpc_endpoints) :
      length(endpoint.vpcs) > 0 &&
      alltrue([
        for vpc in values(endpoint.vpcs) :
        length(trimspace(vpc.vpc_id)) > 0 &&
        length(trimspace(vpc.subnet_id)) > 0
      ])
    ])
    error_message = "Each VPC endpoint must include at least one VPC with non-empty vpc_id and subnet_id."
  }
}

variable "public_endpoint_acl_policies" {
  type = map(object({
    registry_key = string
    entry        = string
    description  = optional(string, null)
  }))
  description = "Explicit public CR endpoint CIDR allowlist entries keyed by stable logical names. The associated registry must opt in to a public endpoint. Do not use 0.0.0.0/0."
  default     = {}

  validation {
    condition = alltrue([
      for policy in values(var.public_endpoint_acl_policies) :
      can(cidrnetmask(policy.entry)) &&
      policy.entry != "0.0.0.0/0"
    ])
    error_message = "Each public endpoint ACL policy must use a valid CIDR and must not use 0.0.0.0/0."
  }
}
