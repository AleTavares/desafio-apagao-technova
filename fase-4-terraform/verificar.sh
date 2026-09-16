#!/usr/bin/env bash
# Verificação da Fase 4 — Terraform / HCL
# Exit 0 = fase concluída | Exit 1 = ainda quebrada
set -uo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DIR" || exit 1

echo "🔍 Verificando Fase 4 — Terraform / HCL..."

if ! command -v terraform >/dev/null 2>&1; then
  echo "  ⚠️  Terraform não encontrado. Rode em máquina com Terraform ou deixe o CI validar."
  exit 1
fi

cleanup() { rm -rf "$DIR/.terraform" "$DIR/.terraform.lock.hcl" "$DIR/saida" >/dev/null 2>&1 || true; }
trap cleanup EXIT

# 1. init
if ! terraform init -input=false -no-color >/tmp/fase4-init.log 2>&1; then
  echo "  ❌ terraform init falhou. Veja /tmp/fase4-init.log"
  tail -n 12 /tmp/fase4-init.log | sed 's/^/     /'
  exit 1
fi
echo "  ✅ terraform init"

# 2. validate
if ! terraform validate -no-color >/tmp/fase4-validate.log 2>&1; then
  echo "  ❌ terraform validate falhou:"
  tail -n 15 /tmp/fase4-validate.log | sed 's/^/     /'
  exit 1
fi
echo "  ✅ terraform validate"

# 3. fmt -check
if ! terraform fmt -check -recursive >/tmp/fase4-fmt.log 2>&1; then
  echo "  ❌ Código não está formatado (rode 'terraform fmt')"
  exit 1
fi
echo "  ✅ Código formatado (fmt)"

# 4. apply
if ! terraform apply -auto-approve -no-color >/tmp/fase4-apply.log 2>&1; then
  echo "  ❌ terraform apply falhou. Veja /tmp/fase4-apply.log"
  tail -n 15 /tmp/fase4-apply.log | sed 's/^/     /'
  exit 1
fi
echo "  ✅ terraform apply"

# 5. flag no arquivo gerado
if [ -f "$DIR/saida/flag.txt" ] && grep -q "FLAG{terraform-hcl-valido-e-plan-limpo}" "$DIR/saida/flag.txt"; then
  echo "  ✅ Flag gerada em saida/flag.txt"
  echo "🎉 Fase 4 CONCLUÍDA!"
  exit 0
else
  echo "  ❌ saida/flag.txt ausente ou sem a flag correta"
  exit 1
fi
