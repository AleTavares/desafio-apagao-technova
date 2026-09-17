#!/usr/bin/env bash
# Verificação da Fase 2 — Docker
# Exit 0 = fase concluída | Exit 1 = ainda quebrada
set -uo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP="$DIR/app"
IMG="technova-fase2-verify"
CID="technova-fase2-verify-run"
ERROS=0

echo "🔍 Verificando Fase 2 — Docker..."

if ! command -v docker >/dev/null 2>&1; then
  echo "  ⚠️  Docker não encontrado neste ambiente. Não é possível validar a Fase 2 aqui."
  echo "     Rode em uma máquina com Docker ou deixe o CI validar."
  exit 1
fi

# Limpeza preventiva
docker rm -f "$CID" >/dev/null 2>&1 || true

# 1. Build
echo "  → docker build..."
if ! docker build -t "$IMG" "$APP" >/tmp/fase2-build.log 2>&1; then
  echo "  ❌ docker build FALHOU. Veja /tmp/fase2-build.log"
  tail -n 15 /tmp/fase2-build.log | sed 's/^/     /'
  exit 1
fi
echo "  ✅ Imagem buildou"

# 2. Usuário não-root (inspeciona a config da imagem)
USR="$(docker inspect --format '{{.Config.User}}' "$IMG" 2>/dev/null)"
if [ -z "$USR" ] || [ "$USR" = "root" ] || [ "$USR" = "0" ]; then
  echo "  ❌ A imagem roda como root (Config.User='$USR'). Defina um USER não-root."
  ERROS=$((ERROS+1))
else
  echo "  ✅ Imagem roda como usuário não-root ('$USR')"
fi

# 3. Sobe o container e testa /flag (com retry — não depende de sleep fixo)
docker run -d -p 3000:3000 --name "$CID" "$IMG" >/dev/null 2>&1
RESP=""
FLAG_OK=0
for i in $(seq 1 15); do
  RESP="$(curl -s http://localhost:3000/flag 2>/dev/null || true)"
  if echo "$RESP" | grep -q "FLAG{docker-image-buildada-e-non-root}"; then
    FLAG_OK=1
    break
  fi
  sleep 2
done
docker rm -f "$CID" >/dev/null 2>&1 || true

if [ "$FLAG_OK" -eq 1 ]; then
  echo "  ✅ Endpoint /flag respondeu com a flag correta"
else
  echo "  ❌ /flag não retornou a flag esperada (última resposta: '${RESP:-vazia}')"
  ERROS=$((ERROS+1))
fi

if [ "$ERROS" -eq 0 ]; then
  echo "🎉 Fase 2 CONCLUÍDA!"
  exit 0
else
  echo "⚠️  Fase 2 ainda tem $ERROS problema(s)."
  exit 1
fi
