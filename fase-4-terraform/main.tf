# ⚠️ TERRAFORM QUEBRADO (Fase 4)
# Este código não passa no `terraform validate` nem no `terraform plan`.
# Sua missão: corrigir os erros de HCL/config até o plan rodar limpo.
#
# Problemas propositais (encontre e corrija):
#   1. Falta o bloco terraform{} com required_providers (provider "local" não declarado)
#   2. A variável "ambiente" é referenciada mas NÃO foi declarada (veja variables.tf)
#   3. O recurso local_file usa um argumento ERRADO ("conteudo" em vez de "content")
#   4. A interpolação usa sintaxe antiga/errada ("${var::ambiente}" com dois-pontos duplos)
#   5. O output referencia um atributo inexistente do recurso

resource "local_file" "flag" {
  filename = "${path.module}/saida/flag.txt"
  conteudo = "Ambiente: ${var::ambiente} - FLAG{terraform-hcl-valido-e-plan-limpo}"
}

output "caminho_flag" {
  value = local_file.flag.caminho_do_arquivo
}
