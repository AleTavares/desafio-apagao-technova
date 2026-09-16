#!/usr/bin/env bash
# Verificação da Fase 7 — Módulos
# Exit 0 = fase concluída | Exit 1 = ainda quebrada
set -uo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DIR" || exit 1
ERROS=0

echo "🔍 Verificando Fase 7 — Módulos..."

# main.tf sem comentários (para análise honesta)
ROOT_SC="$(grep -vE '^\s*#' main.tf | grep -vE '^\s*$')"

# 1. Existe o módulo
if [ -f "$DIR/modules/ambiente/main.tf" ] && [ -f "$DIR/modules/ambiente/variables.tf" ]; then
  echo "  ✅ Módulo modules/ambiente/ existe (main.tf + variables.tf)"
else
  echo "  ❌ Falta o módulo em modules/ambiente/ (main.tf + variables.tf)"
  ERROS=$((ERROS+1))
fi

# 2. O root usa 'module' (pelo menos 2 chamadas)
NCALLS="$(echo "$ROOT_SC" | grep -Ec 'module\s+"')"
if [ "$NCALLS" -ge 2 ]; then
  echo "  ✅ Root chama o módulo $NCALLS vezes"
else
  echo "  ❌ Root precisa chamar o módulo pelo menos 2x (encontrado: $NCALLS)"
  ERROS=$((ERROS+1))
fi

# 3. O root NÃO pode ter mais os recursos local_file duplicados diretamente
if echo "$ROOT_SC" | grep -Eq 'resource\s+"local_file"'; then
  echo "  ❌ O root ainda tem 'resource local_file' — mova a lógica para o módulo"
  ERROS=$((ERROS+1))
else
  echo "  ✅ Root sem recursos local_file duplicados"
fi

# 4. init + apply gerando os arquivos
if command -v terraform >/dev/null 2>&1; then
  cleanup() { rm -rf "$DIR/.terraform" "$DIR/.terraform.lock.hcl" "$DIR/saida" "$DIR/terraform.tfstate" "$DIR/terraform.tfstate.backup" >/dev/null 2>&1 || true; }
  trap cleanup EXIT
  if terraform init -input=false -no-color >/tmp/fase7-init.log 2>&1 \
     && terraform apply -auto-approve -no-color >/tmp/fase7-apply.log 2>&1; then
    echo "  ✅ terraform init + apply"
  else
    echo "  ❌ terraform init/apply falhou:"
    tail -n 12 /tmp/fase7-apply.log /tmp/fase7-init.log 2>/dev/null | sed 's/^/     /'
    ERROS=$((ERROS+1))
  fi

  if [ -f "$DIR/saida/dev.txt" ] && grep -q "ambiente=dev" "$DIR/saida/dev.txt" 2>/dev/null; then
    echo "  ✅ saida/dev.txt gerado"
  else
    echo "  ❌ saida/dev.txt ausente ou com conteúdo errado"
    ERROS=$((ERROS+1))
  fi

  if [ -f "$DIR/saida/staging.txt" ] && grep -q "ambiente=staging" "$DIR/saida/staging.txt" 2>/dev/null; then
    echo "  ✅ saida/staging.txt gerado"
  else
    echo "  ❌ saida/staging.txt ausente ou com conteúdo errado"
    ERROS=$((ERROS+1))
  fi
else
  echo "  ⚠️  Terraform não encontrado — pulando apply (o CI valida)."
fi

# 5. Flag
if [ -f "$DIR/CORRIGIDO.md" ] && grep -q "FLAG{modulos-dry-reutilizaveis}" "$DIR/CORRIGIDO.md" 2>/dev/null; then
  echo "  ✅ Flag da Fase 7 encontrada"
else
  echo "  ❌ Flag ausente ou incorreta em CORRIGIDO.md"
  ERROS=$((ERROS+1))
fi

if [ "$ERROS" -eq 0 ]; then
  echo "🎉 Fase 7 CONCLUÍDA!"
  exit 0
else
  echo "⚠️  Fase 7 ainda tem $ERROS problema(s)."
  exit 1
fi
