# Modulo "ambiente" — saida (opcional).
# Exporta o caminho do arquivo gerado, caso quem chama o modulo precise.

output "caminho" {
  description = "Caminho do arquivo gerado pelo modulo"
  value       = local_file.arquivo.filename
}