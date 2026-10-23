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
      name                    = var.registry_name
      project                 = var.project
      public_endpoint_enabled = var.public_endpoint_enabled
      tags = {
        environment = "production"
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
      name          = "api"
      description   = "Private OCI repository for CI and VKE workloads."
    }
    worker = {
      namespace_key = "application"
      name          = "worker"
      description   = "Private OCI repository for asynchronous workers."
    }
  }

  robot_accounts = {
    ci_push = {
      registry_key = "application"
      username     = var.ci_robot_username
      duration     = 366
      permissions = {
        namespace = {
          resource = var.namespace_name
          actions  = ["PullRepository", "PushRepository"]
        }
      }
    }
    vke_pull = {
      registry_key = "application"
      username     = var.vke_robot_username
      duration     = 366
      permissions = {
        namespace = {
          resource = var.namespace_name
          actions  = ["PullRepository"]
        }
      }
    }
  }

  vpc_endpoints = {
    vke = {
      registry_key = "application"
      vpcs = {
        vke = {
          account_id = var.account_id
          vpc_id     = var.vke_vpc_id
          subnet_id  = var.vke_subnet_id
        }
      }
    }
  }

  public_endpoint_acl_policies = var.public_endpoint_enabled ? {
    build_network = {
      registry_key = "application"
      entry        = var.public_endpoint_cidr
      description  = "Explicit CI build network access."
    }
  } : {}
}
