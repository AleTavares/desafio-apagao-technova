# Fase 4 CORRIGIDA — a variavel "ambiente" agora esta declarada.
# O main.tf a utiliza em var.ambiente.

variable "ambiente" {
  description = "Nome do ambiente"
  type        = string
  default     = "desenvolvimento"
}