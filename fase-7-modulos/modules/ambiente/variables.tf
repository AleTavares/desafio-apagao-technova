# Modulo "ambiente" — variavel de entrada.
# Recebe o nome do ambiente (ex: "dev", "staging") para parametrizar o recurso.

variable "nome" {
  description = "Nome do ambiente a ser gerado"
  type        = string
}