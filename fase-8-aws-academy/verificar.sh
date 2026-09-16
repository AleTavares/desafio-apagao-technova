#!/usr/bin/env bash
# Verificação da Fase 8 — AWS Academy (evidência de execução real)
# Exit 0 = fase concluída | Exit 1 = ainda quebrada
set -uo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DIR" || exit 1
ERROS=0
EV="$DIR/evidencia.md"

echo "🔍 Verificando Fase 8 — AWS Academy (evidência)..."

if [ ! -f "$EV" ]; then
  echo "  ❌ Falta o arquivo evidencia.md (veja o modelo no README)"
  exit 1
fi

# 1. Account ID com 12 dígitos
if grep -Eq '[0-9]{12}' "$EV"; then
  echo "  ✅ Account ID (12 dígitos) presente"
else
  echo "  ❌ Não encontrei um Account ID de 12 dígitos"
  ERROS=$((ERROS+1))
fi

# 2. ARN da AWS
if grep -Eq 'arn:aws:[a-z0-9-]+:' "$EV"; then
  echo "  ✅ ARN da AWS presente (evidência do get-caller-identity)"
else
  echo "  ❌ Não encontrei um ARN da AWS (arn:aws:...)"
  ERROS=$((ERROS+1))
fi

# 3. ID de recurso real (prefixos AWS específicos: vpc-, subnet-, sg-, i-, rtb-, igw-, ...)
if grep -Eq '\b(vpc|subnet|sg|rtb|igw|acl|eni|ami|vol|snap|i)-[0-9a-f]{8,}' "$EV"; then
  echo "  ✅ ID de recurso real criado presente"
else
  echo "  ❌ Não encontrei um ID de recurso real (ex: vpc-0abc...)"
  ERROS=$((ERROS+1))
fi

# 4. Confirmação do destroy
if grep -Eiq 'destroy.*(sucesso|SIM|concluíd|executad)' "$EV"; then
  echo "  ✅ Destruição (terraform destroy) confirmada"
else
  echo "  ❌ Falta confirmar que executou 'terraform destroy' (ex: 'terraform destroy executado com sucesso: SIM')"
  ERROS=$((ERROS+1))
fi

# 5. Flag
if grep -q "FLAG{infra-real-no-learner-lab-e-destruida}" "$EV"; then
  echo "  ✅ Flag da Fase 8 encontrada"
else
  echo "  ❌ Flag ausente ou incorreta em evidencia.md"
  ERROS=$((ERROS+1))
fi

# 6. Segurança: não pode conter credenciais
if grep -Eiq '(aws_secret_access_key|aws_session_token|ASIA[A-Z0-9]{16})' "$EV"; then
  echo "  ❌ PERIGO: evidencia.md parece conter credenciais. Remova-as! Só o Account ID/ARN/IDs de recurso são necessários."
  ERROS=$((ERROS+1))
fi

if [ "$ERROS" -eq 0 ]; then
  echo "🎉 Fase 8 CONCLUÍDA!"
  exit 0
else
  echo "⚠️  Fase 8 ainda tem $ERROS problema(s)."
  exit 1
fi
