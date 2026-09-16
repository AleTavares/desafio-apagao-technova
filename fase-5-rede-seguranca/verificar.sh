#!/usr/bin/env bash
# Verificação da Fase 5 — VPC / Rede / Segurança
# Exit 0 = fase concluída | Exit 1 = ainda quebrada
set -uo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DIR" || exit 1
ERROS=0

echo "🔍 Verificando Fase 5 — VPC / Rede / Segurança..."

# 1. terraform validate
if command -v terraform >/dev/null 2>&1; then
  cleanup() { rm -rf "$DIR/.terraform" "$DIR/.terraform.lock.hcl" >/dev/null 2>&1 || true; }
  trap cleanup EXIT
  if terraform init -input=false -no-color >/tmp/fase5-init.log 2>&1 \
     && terraform validate -no-color >/tmp/fase5-validate.log 2>&1; then
    echo "  ✅ terraform validate"
  else
    echo "  ❌ terraform init/validate falhou:"
    tail -n 12 /tmp/fase5-validate.log /tmp/fase5-init.log 2>/dev/null | sed 's/^/     /'
    ERROS=$((ERROS+1))
  fi
else
  echo "  ⚠️  Terraform não encontrado — pulando validate (o CI valida)."
fi

# 2. Extrai o bloco do Security Group do RDS para análise
# (do 'resource "aws_security_group" "rds"' até a linha que fecha com '}' isolado)
RDS_BLOCK="$(awk '/resource "aws_security_group" "rds"/{f=1} f{print} f&&/^}/{exit}' main.tf)"

# 2a. O bloco do RDS NÃO pode ter 5432 exposto para 0.0.0.0/0
if echo "$RDS_BLOCK" | grep -q "5432" && echo "$RDS_BLOCK" | grep -q "0.0.0.0/0" \
   && echo "$RDS_BLOCK" | grep -Eq 'from_port\s*=\s*5432'; then
  # Verifica se o ingress da 5432 ainda usa cidr_blocks aberto
  if echo "$RDS_BLOCK" | grep -A4 'from_port *= *5432' | grep -q "0.0.0.0/0"; then
    echo "  ❌ Banco AINDA exposto: porta 5432 aceita 0.0.0.0/0 no SG do RDS"
    ERROS=$((ERROS+1))
  fi
fi

# 2b. O SG do RDS deve referenciar o SG da API
if echo "$RDS_BLOCK" | grep -q "aws_security_group.api"; then
  echo "  ✅ SG do RDS referencia o SG da API (menor privilégio)"
else
  echo "  ❌ SG do RDS não referencia o SG da API (use security_groups = [aws_security_group.api.id])"
  ERROS=$((ERROS+1))
fi

# 3. Rota para a internet (0.0.0.0/0 -> Internet Gateway)
if grep -Eq 'gateway_id\s*=\s*aws_internet_gateway' main.tf \
   && grep -q '0.0.0.0/0' main.tf; then
  echo "  ✅ Rota 0.0.0.0/0 -> Internet Gateway presente"
else
  echo "  ❌ Falta a rota 0.0.0.0/0 apontando para o Internet Gateway"
  ERROS=$((ERROS+1))
fi

# 4. Flag
if [ -f "$DIR/CORRIGIDO.md" ] && grep -q "FLAG{rede-segura-banco-fechado-rota-ok}" "$DIR/CORRIGIDO.md" 2>/dev/null; then
  echo "  ✅ Flag da Fase 5 encontrada"
else
  echo "  ❌ Flag ausente ou incorreta em CORRIGIDO.md"
  ERROS=$((ERROS+1))
fi

if [ "$ERROS" -eq 0 ]; then
  echo "🎉 Fase 5 CONCLUÍDA!"
  exit 0
else
  echo "⚠️  Fase 5 ainda tem $ERROS problema(s)."
  exit 1
fi
