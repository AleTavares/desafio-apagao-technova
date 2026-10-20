resource "local_file" "ambiente" {
  filename = "${path.root}/saida/${var.nome}.txt"
  content  = "ambiente=${var.nome}"
}