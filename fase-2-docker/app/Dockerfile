FROM node:20-alpine

WORKDIR /app

# Copia só os manifests primeiro para aproveitar cache de layers
COPY package*.json ./

RUN npm install --production

# Copia o restante do código depois do install
COPY . .

# Usuário não-root embutido na imagem node:alpine
USER node

EXPOSE 3000

CMD ["node", "server.js"]
