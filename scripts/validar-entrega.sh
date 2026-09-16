#!/usr/bin/env bash
# 🚨 Operação TechNova — Orquestrador de validação de ENTREGA
#
# Roda no CI DESTE repositório (o oficial), disparado por um PR de entrega.
# Recebe a URL do repositório do ALUNO, clona, SOBRESCREVE os arquivos de
# validação pelos oficiais (deste repo) — para impedir adulteração — e roda
# os 8 verificadores + o checador do relatório + a integridade.
#
# Uso:
#   bash scripts/validar-entrega.sh <URL_DO_REPO_DO_ALUNO> [BRANCH]
#
# Retorna exit 0 somente se TODAS as fases + relatório passarem.

set -uo pipefail

OFICIAL="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"   # este repo (fonte da verdade)
URL="${1:-}"
BRANCH="${2:-}"

if [ -z "$URL" ]; then
  echo "❌ Uso: bash scripts/validar-entrega.sh <URL_DO_REPO_DO_ALUNO> [BRANCH]"
  exit 1
fi

# Aceita apenas URLs http(s) do GitHub (evita esquemas estranhos / injeção).
# ALLOW_LOCAL_CLONE=1 libera caminhos locais APENAS para testes do professor;
# o CI nunca define essa variável, então em produção só passa GitHub.
if [ "${ALLOW_LOCAL_CLONE:-0}" != "1" ]; then
  if ! printf '%s' "$URL" | grep -qE '^https://github\.com/[A-Za-z0-9._-]+/[A-Za-z0-9._-]+(\.git)?/?$'; then
    echo "❌ URL inválida: '$URL'"
    echo "   Esperado: https://github.com/USUARIO/REPOSITORIO"
    exit 1
  fi
fi

echo "======================================================"
echo "  🚨 VALIDAÇÃO DE ENTREGA — OPERAÇÃO TECHNOVA"
echo "======================================================"
echo "  Repo do aluno: $URL"
[ -n "$BRANCH" ] && echo "  Branch:        $BRANCH"

CLONE="$(mktemp -d)"
trap 'rm -rf "$CLONE"' EXIT

echo ""
echo "→ Clonando repositório do aluno (somente leitura, --depth 1)..."
CLONE_ARGS=(--depth 1 --no-tags)
[ -n "$BRANCH" ] && CLONE_ARGS+=(--branch "$BRANCH")
if ! git -c advice.detachedHead=false clone "${CLONE_ARGS[@]}" "$URL" "$CLONE/repo" 2>/dev/null; then
  echo "❌ Não foi possível clonar '$URL'. Verifique se o repositório é público e a URL está correta."
  exit 1
fi

ALUNO="$CLONE/repo"

# ---------------------------------------------------------------
# ANTIFRAUDE: sobrescreve TODOS os arquivos de validação do aluno
# pelos oficiais deste repositório. Assim, mesmo que o aluno tenha
# alterado qualquer verificar.sh, a validação usa os originais.
# ---------------------------------------------------------------
echo "→ Aplicando arquivos de validação OFICIAIS sobre o clone do aluno..."
FASES=(
  "fase-1-git" "fase-2-docker" "fase-3-compose" "fase-4-terraform"
  "fase-5-rede-seguranca" "fase-6-rds-state" "fase-7-modulos" "fase-8-aws-academy"
)
for f in "${FASES[@]}"; do
  if [ ! -d "$ALUNO/$f" ]; then
    echo "❌ Estrutura inválida: pasta '$f' não existe no repo do aluno."
    exit 1
  fi
  cp "$OFICIAL/$f/verificar.sh" "$ALUNO/$f/verificar.sh"
done
cp "$OFICIAL/scripts/verificar.sh" "$ALUNO/scripts/verificar.sh"

echo ""
echo "======================================================"
echo "  Rodando verificadores oficiais contra o código do aluno"
echo "======================================================"

PASSOU=0
TOTAL="${#FASES[@]}"
declare -a RESULTADO

for i in "${!FASES[@]}"; do
  FASE="${FASES[$i]}"
  N=$(( i + 1 ))
  echo ""
  echo "------------------------------------------------------"
  if bash "$ALUNO/$FASE/verificar.sh"; then
    RESULTADO[$i]="✅ Fase $N ($FASE)"
    PASSOU=$(( PASSOU + 1 ))
  else
    RESULTADO[$i]="❌ Fase $N ($FASE)"
  fi
done

# ---- Relatório Kiro (mesmas regras do job relatorio-kiro) ----
echo ""
echo "------------------------------------------------------"
echo "  Verificando relatorio-kiro.md"
REL_OK=1
FILE="$ALUNO/relatorio-kiro.md"
if [ ! -f "$FILE" ]; then
  echo "  ❌ relatorio-kiro.md não encontrado"
  REL_OK=0
else
  if [ "$(grep -c '_(sua resposta)_' "$FILE" || true)" -gt 0 ]; then
    echo "  ❌ Ainda há placeholders '(sua resposta)' não preenchidos"
    REL_OK=0
  fi
  for fase in "Fase 1" "Fase 2" "Fase 3" "Fase 4" "Fase 5" "Fase 6" "Fase 7" "Fase 8"; do
    if ! grep -q "$fase" "$FILE"; then
      echo "  ❌ Falta relatar a $fase no relatório"
      REL_OK=0
    fi
  done
  if ! grep -Eq '\*\*RA:\*\*\s*\S' "$FILE"; then
    echo "  ❌ Preencha seu RA no relatório"
    REL_OK=0
  fi
fi
[ "$REL_OK" -eq 1 ] && echo "  ✅ Relatório Kiro válido"

echo ""
echo "======================================================"
echo "  PLACAR FINAL DA ENTREGA"
echo "======================================================"
for r in "${RESULTADO[@]}"; do echo "  $r"; done
if [ "$REL_OK" -eq 1 ]; then echo "  ✅ Relatório Kiro"; else echo "  ❌ Relatório Kiro"; fi
echo "------------------------------------------------------"
echo "  $PASSOU de $TOTAL fases concluídas."

if [ "$PASSOU" -eq "$TOTAL" ] && [ "$REL_OK" -eq 1 ]; then
  echo ""
  echo "  🎉 ENTREGA VÁLIDA! A TechNova está de pé. O mascote é seu! 🦖"
  exit 0
else
  echo ""
  echo "  ⚠️  Entrega incompleta. Ainda faltam itens acima."
  exit 1
fi
