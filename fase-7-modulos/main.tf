# ⚠️ CÓDIGO DUPLICADO (Fase 7)
# Este main.tf viola o princípio DRY: o mesmo bloco foi COPIADO E COLADO para
# dois ambientes (dev e staging). Sua missão é REFATORAR isso em um MÓDULO
# reutilizável e chamar o módulo duas vezes (uma por ambiente).
#
# Objetivo:
#   1. Criar um módulo em ./modules/ambiente/ que gere um arquivo de saída
#      contendo o nome do ambiente (recebido por variável).
#   2. Substituir os dois recursos duplicados abaixo por DUAS chamadas de módulo
#      (module "dev" e module "staging"), passando o nome do ambiente por variável.
#   3. O root NÃO pode mais ter recursos "local_file" duplicados — deve usar o módulo.
#
# Esta fase usa o provider "local" (não precisa de AWS).

terraform {
  required_version = ">= 1.0"
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
  }
}

# ---------- MÓDULO reutilizável — ambiente DEV ----------
module "dev" {
  source = "./modules/ambiente"
  nome   = "dev"
}

# ---------- MÓDULO reutilizável — ambiente STAGING ----------
module "staging" {
  source = "./modules/ambiente"
  nome   = "staging"
}
