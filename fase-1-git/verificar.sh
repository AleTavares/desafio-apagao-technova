#!/usr/bin/env bash
# Verificação da Fase 1 — Git
# Exit 0 = fase concluída | Exit 1 = ainda quebrada
set -uo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ERROS=0

echo "🔍 Verificando Fase 1 — Git..."

# 1. A senha vazada NÃO pode existir mais em database.yml
if grep -q "SenhaSuperSecreta123" "$DIR/config/database.yml" 2>/dev/null; then
  echo "  ❌ A senha vazada ('SenhaSuperSecreta123') ainda está em config/database.yml"
  ERROS=$((ERROS+1))
else
  echo "  ✅ Senha vazada removida de database.yml"
fi

# 2. database.yml deve usar variável de ambiente
if grep -Eq '\$\{[A-Za-z_]+\}' "$DIR/config/database.yml" 2>/dev/null; then
  echo "  ✅ database.yml usa variável de ambiente"
else
  echo "  ❌ database.yml não usa variável de ambiente (ex: \${DB_PASSWORD})"
  ERROS=$((ERROS+1))
fi

# 3. app.env deve estar em desenvolvimento
if grep -q "^APP_ENV=desenvolvimento" "$DIR/config/app.env" 2>/dev/null; then
  echo "  ✅ APP_ENV=desenvolvimento"
else
  echo "  ❌ APP_ENV precisa ser 'desenvolvimento' em config/app.env"
  ERROS=$((ERROS+1))
fi

# 4. .gitignore ignorando *.env
if [ -f "$DIR/config/.gitignore" ] && grep -q '\*\.env' "$DIR/config/.gitignore" 2>/dev/null; then
  echo "  ✅ config/.gitignore ignora *.env"
else
  echo "  ❌ Falta config/.gitignore ignorando *.env"
  ERROS=$((ERROS+1))
fi

# 5. Flag correta
if [ -f "$DIR/config/CORRIGIDO.md" ] && grep -q "FLAG{git-segredo-removido-e-config-corrigida}" "$DIR/config/CORRIGIDO.md" 2>/dev/null; then
  echo "  ✅ Flag da Fase 1 encontrada"
else
  echo "  ❌ Flag ausente ou incorreta em config/CORRIGIDO.md"
  ERROS=$((ERROS+1))
fi

if [ "$ERROS" -eq 0 ]; then
  echo "🎉 Fase 1 CONCLUÍDA!"
  exit 0
else
  echo "⚠️  Fase 1 ainda tem $ERROS problema(s)."
  exit 1
fi
