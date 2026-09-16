# Fase 2 — Docker: A Imagem que Não Sobe 🐳

## O Incidente

> "A imagem da API não builda. E quando o time forçou uma versão antiga, ela subiu rodando como **root** — a segurança reprovou na hora. Preciso de uma imagem que builde limpa e rode com usuário sem privilégios." — CTO

O `Dockerfile` em `app/Dockerfile` está cheio de erros do deploy de sexta.

---

## Seu Objetivo

Consertar o `app/Dockerfile` para que:

1. A imagem **builde sem erros**
2. Use uma **imagem base com versão fixa** (não `latest`) — recomendado `node:20-alpine`
3. **Aproveite o cache de layers** (copie `package*.json` e rode o install **antes** de copiar o resto)
4. Rode como **usuário não-root**
5. **Exponha a porta 3000**
6. Inicie o arquivo correto (`server.js`)

Depois de buildar e rodar o container, a aplicação responde em `/flag` com a flag desta fase.

---

## Critério da Flag ✅

O CI desta fase constrói a imagem, roda o container e valida:

- [ ] `docker build` conclui **sem erros**
- [ ] O container **roda como usuário não-root** (`USER` definido, uid != 0)
- [ ] O endpoint `http://localhost:3000/flag` responde com:

```json
{ "flag": "FLAG{docker-image-buildada-e-non-root}" }
```

> A flag já está no código da aplicação (`app/server.js`). Você **não precisa** editar o `server.js` — o desafio é fazer a **imagem** buildar e rodar corretamente. A flag só é acessível quando o container sobe direito.

---

## 💡 Dica de Uso da IA

Ataque **um erro por vez**. Um bom fluxo:

> "Rodei `docker build` e recebi este erro: [cole o erro]. Qual a causa e como corrijo essa linha específica do Dockerfile?"

Depois de cada correção, **rode `docker build` de novo** e veja o próximo erro. Não peça para a IA "reescrever o Dockerfile inteiro" de primeira — você aprende mais e evita que ela invente coisas. Registre no `relatorio-kiro.md` como você foi destravando erro a erro.

### Testar localmente

```bash
cd app
docker build -t technova-fase2 .
docker run -d -p 3000:3000 --name fase2 technova-fase2
curl http://localhost:3000/flag
docker rm -f fase2
```
