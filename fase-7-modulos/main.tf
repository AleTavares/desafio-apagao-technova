terraform {
  required_version = ">= 1.0"
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
  }
}

module "dev" {
  source = "./modules/ambiente"
  nome   = "dev"
}

module "staging" {
  source = "./modules/ambiente"
  nome   = "staging"
}
