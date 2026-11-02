variable "region" {
  type        = string
  description = "Volcengine region for the CR resources and VKE VPC."
}

variable "registry_name" {
  type        = string
  description = "Unique CR registry name, 3-30 lowercase letters, digits, and hyphens."
}

variable "namespace_name" {
  type        = string
  description = "Namespace to which CI receives push permission and VKE receives pull permission."
}

variable "project" {
  type        = string
  description = "Existing Volcengine project name."
  default     = "default"
}

variable "ci_robot_username" {
  type        = string
  description = "Existing CI robot account name in crrobot@name form."
}

variable "vke_robot_username" {
  type        = string
  description = "Existing VKE robot account name in crrobot@name form."
}

variable "account_id" {
  type        = number
  description = "Volcengine account ID that owns the VKE VPC."
}

variable "vke_vpc_id" {
  type        = string
  description = "Existing VKE cluster VPC ID for the CR private endpoint."
}

variable "vke_subnet_id" {
  type        = string
  description = "Existing subnet ID in the VKE VPC for the CR private endpoint."
}

variable "public_endpoint_enabled" {
  type        = bool
  description = "Whether to opt in to the CR public endpoint. Leave false for VKE private pulls."
  default     = false
}

variable "public_endpoint_cidr" {
  type        = string
  description = "Trusted CI CIDR when public_endpoint_enabled is true. It must not be 0.0.0.0/0."
  default     = "203.0.113.0/24"
}
