# Fase 4 CORRIGIDA — HCL valido, validate e plan limpos.
# Correcoes aplicadas:
#   1. Adicionado o bloco terraform{} com required_providers do provider "local"
#   2. Variavel "ambiente" declarada em variables.tf
#   3. Argumento "conteudo" corrigido para "content"
#   4. Interpolacao "${var::ambiente}" corrigida para "${var.ambiente}"
#   5. Output passa a referenciar o atributo correto "filename"

terraform {
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.4"
    }
  }
}

resource "local_file" "flag" {
  filename = "${path.module}/saida/flag.txt"
  content  = "Ambiente: ${var.ambiente} - FLAG{terraform-hcl-valido-e-plan-limpo}"
}

output "caminho_flag" {
  value = local_file.flag.filename
}