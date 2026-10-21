# Modulo "ambiente" — logica reutilizavel.
# Gera um arquivo de saida com o nome do ambiente recebido por variavel.
# Usa path.root para escrever na pasta da configuracao RAIZ (quem chama o modulo),
# e nao dentro da pasta do proprio modulo.

resource "local_file" "arquivo" {
  filename = "${path.root}/saida/${var.nome}.txt"
  content  = "ambiente=${var.nome}"
}