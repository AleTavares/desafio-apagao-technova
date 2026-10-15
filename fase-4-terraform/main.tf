terraform {
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
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
