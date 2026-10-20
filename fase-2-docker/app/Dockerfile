# 1. Imagem base leve e com versão fixa
FROM node:20-alpine

# Define o diretório de trabalho
WORKDIR /app

# 2 e 3. Copia apenas os manifestos de dependências com permissão para o usuário node
COPY --chown=node:node package*.json ./
RUN npm install --production

# Copia o restante do código com permissão para o usuário node
COPY --chown=node:node . .

# 4. Muda para usuário não-root
USER node

# 5. Expõe a porta 3000
EXPOSE 3000

# 6. Inicia a aplicação usando server.js
CMD ["node", "server.js"]