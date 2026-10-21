# Fase 2 CORRIGIDA — imagem builda, roda como nao-root e expoe a porta 3000.

# (1) Imagem base com versao FIXA e enxuta (nao usar "latest").
FROM node:20-alpine

# Diretorio de trabalho da aplicacao.
WORKDIR /app

# (2)+(3) Copia apenas os manifests primeiro e instala as dependencias ANTES
# de copiar o resto do codigo. Isso aproveita o cache de layers do Docker.
# O curinga package*.json cobre o package-lock.json quando ele existir,
# sem quebrar o build quando ele nao existe.
COPY package*.json ./
RUN npm install --production

# Agora sim copia o restante do codigo-fonte.
COPY . .

# (4) Cria um usuario sem privilegios e passa a rodar como ele.
# A imagem alpine do Node ja traz o usuario "node"; usamos ele.
USER node

# (5) Documenta/expoe a porta em que a API escuta.
EXPOSE 3000

# (6) Inicia o arquivo correto (server.js, nao app.js).
CMD ["node", "server.js"]