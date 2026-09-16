# Fase 1 — Git: O Segredo que Vazou 🔓

## O Incidente

> "Antes de ir embora na sexta, o dev commitou as credenciais do banco direto no repositório. E ainda por cima deixou o arquivo de configuração da aplicação apontando para o ambiente errado. Isso precisa sumir **agora**." — CTO

Na pressa do deploy, dois erros clássicos de versionamento aconteceram nesta pasta:

1. Um arquivo **`config/database.yml`** contém uma **senha real hardcoded** (segredo vazado).
2. O arquivo **`config/app.env`** está com a variável de ambiente **errada** (aponta para `producao` quando deveria apontar para `desenvolvimento`).
3. Não existe um **`.gitignore`** protegendo arquivos sensíveis nesta fase.

---

## Seu Objetivo

1. **Remover o segredo** do arquivo `config/database.yml`. A senha real **não pode existir** no arquivo — substitua por uma referência a variável de ambiente (ex: `${DB_PASSWORD}`).
2. **Corrigir** o `config/app.env`: a variável `APP_ENV` deve valer `desenvolvimento`.
3. **Criar** um arquivo `config/.gitignore` que ignore arquivos sensíveis (`*.env`, `*.pem`, `secrets.*`).
4. **Criar** o arquivo `config/CORRIGIDO.md` contendo **exatamente** a flag desta fase (veja abaixo).

---

## Critério da Flag ✅

O CI desta fase só fica verde quando **todas** as condições forem satisfeitas:

- [ ] `config/database.yml` **NÃO contém** a string da senha vazada (`SenhaSuperSecreta123`)
- [ ] `config/database.yml` **contém** uma referência a variável de ambiente (`${DB_PASSWORD}` ou `${...}`)
- [ ] `config/app.env` tem `APP_ENV=desenvolvimento`
- [ ] Existe o arquivo `config/.gitignore` ignorando `*.env`
- [ ] Existe o arquivo `config/CORRIGIDO.md` com a flag exata:

```
FLAG{git-segredo-removido-e-config-corrigida}
```

---

## 💡 Dica de Uso da IA

Não peça "conserta a fase 1". Peça algo específico e verificável, por exemplo:

> "Este arquivo `database.yml` tem uma senha hardcoded. Como eu removo o segredo e passo a usar uma variável de ambiente, seguindo boas práticas? Me explique o porquê."

E depois **valide** com seus próprios olhos e com `grep` se a senha realmente sumiu. Registre isso no `relatorio-kiro.md`.

> **Atenção conceitual:** em um caso real, remover o segredo do arquivo **não basta** — ele continua no histórico do Git e a credencial deve ser **rotacionada**. Comente no seu relatório como você trataria isso no mundo real (ex: `git filter-repo`, rotação da senha no banco).
