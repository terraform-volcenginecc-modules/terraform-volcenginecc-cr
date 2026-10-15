variable "region" {
  type        = string
  description = "Volcengine region for the CR resources."
}

variable "registry_name" {
  type        = string
  description = "Unique CR registry name, 3-30 lowercase letters, digits, and hyphens."
}

variable "namespace_name" {
  type        = string
  description = "Private repository namespace name."
}

variable "repository_name" {
  type        = string
  description = "Private OCI repository name."
  default     = "api"
}

variable "project" {
  type        = string
  description = "Existing Volcengine project name."
  default     = "default"
}
