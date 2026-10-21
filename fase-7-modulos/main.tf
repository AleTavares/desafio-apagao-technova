# Fase 7 CORRIGIDA — princípio DRY aplicado.
# Os dois recursos local_file duplicados (dev e staging) foram movidos para o
# modulo reutilizavel em ./modules/ambiente/. Agora o root apenas CHAMA o modulo
# duas vezes, passando o nome do ambiente por variavel.

terraform {
  required_version = ">= 1.0"
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
  }
}

# Uma unica definicao de logica (o modulo), reutilizada por ambiente.
module "dev" {
  source = "./modules/ambiente"
  nome   = "dev"
}

module "staging" {
  source = "./modules/ambiente"
  nome   = "staging"
}