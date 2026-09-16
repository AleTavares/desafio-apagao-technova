#!/usr/bin/env bash
# 🚨 Operação TechNova — Verificador local do desafio
# Roda o verificador de cada fase e mostra um placar.
# Use antes de abrir o PR para ver o que já passou.
#
# Uso:
#   bash scripts/verificar.sh          # roda todas as fases
#   bash scripts/verificar.sh 3        # roda só a fase 3

set -uo pipefail

RAIZ="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

FASES=(
  "fase-1-git"
  "fase-2-docker"
  "fase-3-compose"
  "fase-4-terraform"
  "fase-5-rede-seguranca"
  "fase-6-rds-state"
  "fase-7-modulos"
  "fase-8-aws-academy"
)

# Se passar um número, roda só aquela fase
if [ "$#" -ge 1 ]; then
  IDX=$(( $1 - 1 ))
  if [ "$IDX" -ge 0 ] && [ "$IDX" -lt "${#FASES[@]}" ]; then
    bash "$RAIZ/${FASES[$IDX]}/verificar.sh"
    exit $?
  else
    echo "Fase inválida: $1 (use 1 a 8)"
    exit 1
  fi
fi

echo "======================================================"
echo "  🚨 OPERAÇÃO TECHNOVA — PLACAR DO DESAFIO"
echo "======================================================"

PASSOU=0
TOTAL="${#FASES[@]}"
declare -a RESULTADO

for i in "${!FASES[@]}"; do
  FASE="${FASES[$i]}"
  N=$(( i + 1 ))
  echo ""
  echo "------------------------------------------------------"
  if bash "$RAIZ/$FASE/verificar.sh"; then
    RESULTADO[$i]="✅ Fase $N ($FASE)"
    PASSOU=$(( PASSOU + 1 ))
  else
    RESULTADO[$i]="❌ Fase $N ($FASE)"
  fi
done

echo ""
echo "======================================================"
echo "  PLACAR FINAL"
echo "======================================================"
for r in "${RESULTADO[@]}"; do
  echo "  $r"
done
echo "------------------------------------------------------"
echo "  $PASSOU de $TOTAL fases concluídas."

if [ "$PASSOU" -eq "$TOTAL" ]; then
  echo ""
  echo "  🎉 TODAS AS FASES PASSARAM! Não esqueça de preencher"
  echo "     o relatorio-kiro.md e abrir o PR. O mascote é seu! 🦖"
  exit 0
else
  echo ""
  echo "  ⚠️  Ainda faltam fases. Continue, engenheiro(a)! ☕"
  exit 1
fi
