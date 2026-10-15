terraform {
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
  }
}

resource "local_file" "ambiente" {
  filename = "${path.root}/saida/${var.nome}.txt"
  content  = "ambiente=${var.nome}"
}
