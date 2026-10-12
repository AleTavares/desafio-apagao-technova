# ⚠️ DOCKERFILE QUEBRADO (Fase 2)
# Este Dockerfile tem VÁRIOS problemas. Sua missão é consertá-lo para que:
#   - a imagem builde sem erros
#   - a aplicação rode como usuário NÃO-root
#   - a porta 3000 seja exposta
#
# Problemas propositais (encontre e corrija):
#   1. A imagem base usa a tag flutuante "latest" (deveria ser uma versão fixa, ex: node:20-alpine)
#   2. O COPY do código acontece ANTES do npm install, quebrando o cache de layers
#   3. Há um COPY de um arquivo que NÃO existe (package-lock.json), quebrando o build.
#      A correção correta é copiar package*.json e rodar o install ANTES de copiar o resto (cache de layers).
#   4. Roda como root (não cria nem usa um usuário não-root)
#   5. Falta EXPOR a porta 3000
#   6. O CMD está com o nome do arquivo errado ("app.js" em vez de "server.js")

FROM node:20-alpine

WORKDIR /app

# Copia apenas os manifests primeiro para aproveitar cache de layers
COPY package*.json ./

RUN npm install --production

# Copia o restante do código depois do install
COPY . .

# Cria usuário não-root e assume identidade
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
USER appuser

EXPOSE 3000

CMD ["node", "server.js"]
