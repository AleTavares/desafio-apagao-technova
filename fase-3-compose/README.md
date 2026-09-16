# Fase 3 — Docker Compose: A Stack que Não Levanta 🧱

## O Incidente

> "O ambiente local não sobe. A API reclama que não acha o banco, o healthcheck do Postgres fica vermelho e ninguém consegue trabalhar. Preciso que `docker compose up` deixe tudo **saudável e conectado**." — CTO

O `docker-compose.yml` desta pasta orquestra a **API + PostgreSQL**, mas o deploy de sexta deixou a stack completamente quebrada.

---

## Seu Objetivo

Consertar o `docker-compose.yml` para que a stack suba **saudável** e a API **conecte ao PostgreSQL**. Há 5 problemas plantados (veja os comentários no topo do arquivo):

1. API e Postgres em **redes diferentes** — coloque ambos na **mesma rede**
2. Falta a variável **`DB_PASSWORD`** no serviço `api`
3. **`DB_HOST`** da API aponta para o nome de serviço errado
4. **Healthcheck** do Postgres usa comando inexistente (`pg_ready` → `pg_isready`)
5. **`depends_on`** da API não espera o banco ficar **saudável** (`condition: service_healthy`)

Quando tudo estiver certo, a API conecta no banco e o endpoint `/flag` responde.

---

## Critério da Flag ✅

O CI sobe a stack com `docker compose up` e valida:

- [ ] `docker compose config` é **válido**
- [ ] A stack sobe e o **PostgreSQL fica healthy**
- [ ] O endpoint `http://localhost:3000/flag` responde com:

```json
{ "flag": "FLAG{compose-stack-saudavel-e-conectada}" }
```

> A flag está no código da API (`app/server.js`) e **só é liberada quando a query ao banco funciona**. Ou seja: se a rede/env/healthcheck estiverem errados, a flag não aparece. Você **não precisa** editar o `server.js`.

---

## 💡 Dica de Uso da IA

Vá por partes e use os logs como evidência:

> "Rodei `docker compose up` e a API retorna 503 em `/flag` com 'sem conexão com o banco'. Aqui está meu docker-compose.yml: [cole]. Quais problemas de rede/variáveis podem causar isso?"

Depois valide cada hipótese: `docker compose ps` (o postgres está healthy?), `docker compose logs api` (qual host ela tenta?). Documente no `relatorio-kiro.md` como você isolou cada um dos 5 problemas.

### Testar localmente

```bash
docker compose up -d --build
docker compose ps            # postgres deve estar (healthy)
curl http://localhost:3000/flag
docker compose down
```
