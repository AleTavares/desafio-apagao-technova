#!/usr/bin/env bash
# Verificação da Fase 6 — RDS + Remote State
# Exit 0 = fase concluída | Exit 1 = ainda quebrada
set -uo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DIR" || exit 1
ERROS=0

echo "🔍 Verificando Fase 6 — RDS + Remote State..."

# Cria uma versão do main.tf SEM comentários e SEM linhas em branco,
# para a análise não ser enganada por instruções nos comentários.
SEMCOMENT="$(grep -vE '^\s*#' main.tf | grep -vE '^\s*$')"

# 1. terraform validate (backend desabilitado)
if command -v terraform >/dev/null 2>&1; then
  cleanup() { rm -rf "$DIR/.terraform" "$DIR/.terraform.lock.hcl" >/dev/null 2>&1 || true; }
  trap cleanup EXIT
  if terraform init -backend=false -input=false -no-color >/tmp/fase6-init.log 2>&1 \
     && terraform validate -no-color >/tmp/fase6-validate.log 2>&1; then
    echo "  ✅ terraform validate"
  else
    echo "  ❌ terraform init/validate falhou:"
    tail -n 12 /tmp/fase6-validate.log /tmp/fase6-init.log 2>/dev/null | sed 's/^/     /'
    ERROS=$((ERROS+1))
  fi
else
  echo "  ⚠️  Terraform não encontrado — pulando validate (o CI valida)."
fi

# 2. Backend: encrypt = true
if echo "$SEMCOMENT" | grep -Eq 'encrypt\s*=\s*true'; then
  echo "  ✅ Backend S3 com encrypt = true"
else
  echo "  ❌ Backend S3 sem 'encrypt = true'"
  ERROS=$((ERROS+1))
fi

# 3. Backend: dynamodb_table
if echo "$SEMCOMENT" | grep -Eq 'dynamodb_table\s*='; then
  echo "  ✅ Backend S3 com dynamodb_table (locking)"
else
  echo "  ❌ Backend S3 sem 'dynamodb_table'"
  ERROS=$((ERROS+1))
fi

# 4. RDS: publicly_accessible = false (e NÃO pode existir = true)
if echo "$SEMCOMENT" | grep -Eq 'publicly_accessible\s*=\s*true'; then
  echo "  ❌ RDS ainda está público (publicly_accessible = true)"
  ERROS=$((ERROS+1))
elif echo "$SEMCOMENT" | grep -Eq 'publicly_accessible\s*=\s*false'; then
  echo "  ✅ RDS não é público (publicly_accessible = false)"
else
  echo "  ❌ Falta 'publicly_accessible = false' no RDS"
  ERROS=$((ERROS+1))
fi

# 5. RDS: storage_encrypted = true (e NÃO pode existir = false)
if echo "$SEMCOMENT" | grep -Eq 'storage_encrypted\s*=\s*false'; then
  echo "  ❌ Armazenamento do RDS sem encriptação (storage_encrypted = false)"
  ERROS=$((ERROS+1))
elif echo "$SEMCOMENT" | grep -Eq 'storage_encrypted\s*=\s*true'; then
  echo "  ✅ RDS com storage_encrypted = true"
else
  echo "  ❌ Falta 'storage_encrypted = true' no RDS"
  ERROS=$((ERROS+1))
fi

# 6. RDS: db_subnet_group_name (fora de comentário)
if echo "$SEMCOMENT" | grep -Eq 'db_subnet_group_name\s*='; then
  echo "  ✅ RDS com db_subnet_group_name (subnets privadas)"
else
  echo "  ❌ RDS sem 'db_subnet_group_name'"
  ERROS=$((ERROS+1))
fi

# 7. Flag
if [ -f "$DIR/CORRIGIDO.md" ] && grep -q "FLAG{rds-privado-e-state-protegido}" "$DIR/CORRIGIDO.md" 2>/dev/null; then
  echo "  ✅ Flag da Fase 6 encontrada"
else
  echo "  ❌ Flag ausente ou incorreta em CORRIGIDO.md"
  ERROS=$((ERROS+1))
fi

if [ "$ERROS" -eq 0 ]; then
  echo "🎉 Fase 6 CONCLUÍDA!"
  exit 0
else
  echo "⚠️  Fase 6 ainda tem $ERROS problema(s)."
  exit 1
fi
