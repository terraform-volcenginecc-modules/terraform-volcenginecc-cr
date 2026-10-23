provider "volcenginecc" {
  region = var.region
}

module "cr" {
  source  = "terraform-volcenginecc-modules/cr/volcenginecc"
  version = "~> 1.0"

  region     = var.region
  account_id = var.account_id

  registries = {
    application = {
      name    = var.registry_name
      project = var.project
      tags = {
        environment = "development"
        managed_by  = "terraform"
      }
    }
  }

  namespaces = {
    application = {
      registry_key = "application"
      name         = var.namespace_name
      project      = var.project
    }
  }

  repositories = {
    api = {
      namespace_key = "application"
      name          = var.repository_name
      description   = "Private application OCI image repository."
      access_level  = "Private"
    }
  }
}
