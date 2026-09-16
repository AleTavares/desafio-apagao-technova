#!/usr/bin/env bash
# Verificação da Fase 3 — Docker Compose
# Exit 0 = fase concluída | Exit 1 = ainda quebrada
set -uo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DIR" || exit 1

echo "🔍 Verificando Fase 3 — Docker Compose..."

if ! command -v docker >/dev/null 2>&1; then
  echo "  ⚠️  Docker não encontrado. Rode em máquina com Docker ou deixe o CI validar."
  exit 1
fi

# Descobre o comando do compose (plugin v2 ou binário legado)
if docker compose version >/dev/null 2>&1; then
  DC="docker compose"
elif command -v docker-compose >/dev/null 2>&1; then
  DC="docker-compose"
else
  echo "  ⚠️  Docker Compose não encontrado."
  exit 1
fi

cleanup() { $DC down -v >/dev/null 2>&1 || true; }
trap cleanup EXIT

# 1. Config válida
if ! $DC config >/tmp/fase3-config.log 2>&1; then
  echo "  ❌ docker compose config inválido. Veja /tmp/fase3-config.log"
  tail -n 10 /tmp/fase3-config.log | sed 's/^/     /'
  exit 1
fi
echo "  ✅ docker-compose.yml é válido"

# 2. Sobe a stack
echo "  → subindo a stack (pode levar ~1 min)..."
$DC up -d --build >/tmp/fase3-up.log 2>&1 || {
  echo "  ❌ 'compose up' falhou. Veja /tmp/fase3-up.log"
  tail -n 15 /tmp/fase3-up.log | sed 's/^/     /'
  exit 1
}

# 3. Aguarda a API responder /flag (até ~60s)
FLAG_OK=0
for i in $(seq 1 20); do
  RESP="$(curl -s http://localhost:3000/flag 2>/dev/null || true)"
  if echo "$RESP" | grep -q "FLAG{compose-stack-saudavel-e-conectada}"; then
    FLAG_OK=1
    break
  fi
  sleep 3
done

if [ "$FLAG_OK" -eq 1 ]; then
  echo "  ✅ /flag respondeu com a flag correta (API conectada ao banco)"
  echo "🎉 Fase 3 CONCLUÍDA!"
  exit 0
else
  echo "  ❌ /flag não retornou a flag (última resposta: '${RESP:-vazia}')"
  echo "     Dica: verifique rede compartilhada, DB_HOST, DB_PASSWORD e healthcheck."
  exit 1
fi
