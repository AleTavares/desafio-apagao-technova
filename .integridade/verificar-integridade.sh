#!/usr/bin/env bash
# 🔒 Verificador de INTEGRIDADE — Operação TechNova
#
# Garante que o aluno NÃO alterou os arquivos de validação do desafio
# (os verificar.sh de cada fase, o validador local e o workflow do CI).
#
# Como funciona:
#   - O professor congelou os hashes SHA-256 em .integridade/manifest.sha256.
#   - Este script recalcula os hashes dos arquivos atuais e compara.
#   - Se QUALQUER arquivo de validação foi alterado/removido, retorna exit 1
#     e o desafio é REPROVADO (o gate final depende deste job).
#
# Uso: bash .integridade/verificar-integridade.sh

set -uo pipefail

# RAIZ = repositório a ser checado. Localmente é a pasta-pai do script.
# No CI (validação confiável), o verificador OFICIAL é executado com RAIZ_OVERRIDE
# apontando para o repositório do ALUNO, e MANIFEST_OVERRIDE para o manifesto oficial.
RAIZ="${RAIZ_OVERRIDE:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
MANIFEST="${MANIFEST_OVERRIDE:-$RAIZ/.integridade/manifest.sha256}"

echo "======================================================"
echo "  🔒 VERIFICAÇÃO DE INTEGRIDADE DO DESAFIO"
echo "======================================================"

if [ ! -f "$MANIFEST" ]; then
  echo "❌ Manifesto de integridade não encontrado (.integridade/manifest.sha256)."
  echo "   Não remova este arquivo — ele prova que a validação não foi adulterada."
  exit 1
fi

ERROS=0

# Lê o manifesto no formato: <sha256>  <caminho>.
# Aceita apenas linhas cujo primeiro campo é um hash SHA-256 válido (64 hex),
# ignorando comentários, linhas em branco e qualquer ruído.
while IFS= read -r linha || [ -n "$linha" ]; do
  esperado="${linha%% *}"
  # valida que 'esperado' é exatamente 64 caracteres hexadecimais
  if ! printf '%s' "$esperado" | grep -qE '^[0-9a-fA-F]{64}$'; then
    continue
  fi
  # remove o hash + espaços do início para obter o caminho
  arquivo="${linha#* }"
  arquivo="${arquivo#"${arquivo%%[![:space:]]*}"}"

  if [ ! -f "$RAIZ/$arquivo" ]; then
    echo "  ❌ Arquivo de validação AUSENTE: $arquivo"
    ERROS=$((ERROS+1))
    continue
  fi

  atual="$(sha256sum "$RAIZ/$arquivo" | awk '{print $1}')"
  if [ "$atual" != "$esperado" ]; then
    echo "  ❌ ALTERADO: $arquivo"
    echo "       esperado: $esperado"
    echo "       atual:    $atual"
    ERROS=$((ERROS+1))
  else
    echo "  ✅ OK: $arquivo"
  fi
done < "$MANIFEST"

echo "------------------------------------------------------"
if [ "$ERROS" -eq 0 ]; then
  echo "🎉 Integridade confirmada — nenhum arquivo de validação foi alterado."
  exit 0
else
  echo "🚫 DESAFIO REPROVADO POR INTEGRIDADE ($ERROS arquivo(s) alterado(s)/ausente(s))."
  echo "   Os arquivos de validação (verificar.sh e o workflow) NÃO podem ser modificados."
  echo "   Restaure a versão original para continuar."
  exit 1
fi
