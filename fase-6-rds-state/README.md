# Fase 6 — RDS + Remote State: Dados Expostos e State Desprotegido 💾

## O Incidente

> "Duas notícias ruins. Primeira: o banco RDS foi criado **acessível publicamente e sem encriptação** — a auditoria vai nos crucificar. Segunda: o state do Terraform está num bucket **sem encriptação e sem lock** — se dois deploys rodarem juntos, corrompe tudo. Conserta a camada de dados e a proteção do state." — CTO

O `main.tf` desta pasta define o **RDS** e o **backend S3** do state, ambos mal configurados.

---

## Seu Objetivo

Corrigir o `main.tf`:

**Backend remoto (`terraform { backend "s3" { ... } }`):**
1. Adicionar **`encrypt = true`** (o state contém segredos)
2. Adicionar **`dynamodb_table`** para o state locking (ex: `"technova-terraform-locks"`)

**RDS (`aws_db_instance`):**
3. **`publicly_accessible = false`** (o banco não pode ser público)
4. **`storage_encrypted = true`** (armazenamento encriptado)
5. Adicionar **`db_subnet_group_name`** (o banco fica em subnets privadas)

Depois de corrigir, crie o arquivo **`CORRIGIDO.md`** com a flag.

---

## Critério da Flag ✅

O CI valida (análise do código + `terraform validate`):

- [ ] `terraform validate` **sem erros** (validação com backend desabilitado no CI)
- [ ] Backend S3 com **`encrypt = true`**
- [ ] Backend S3 com **`dynamodb_table`** definido
- [ ] RDS com **`publicly_accessible = false`**
- [ ] RDS com **`storage_encrypted = true`**
- [ ] RDS com **`db_subnet_group_name`** presente
- [ ] Existe `CORRIGIDO.md` com a flag:

```
FLAG{rds-privado-e-state-protegido}
```

> **Nota:** o `terraform validate` no CI roda com `-backend=false` (não precisa acessar o bucket real). A execução de verdade acontece na **Fase 8** (Learner Lab).

---

## 💡 Dica de Uso da IA

Separe os dois assuntos em prompts distintos — não misture "conserta o RDS e o backend" num pedido só:

> "Neste `aws_db_instance`, quais atributos garantem que o banco NÃO seja público e que o armazenamento seja encriptado? Explique cada um."

E depois, num prompt separado:

> "Como configuro `encrypt` e `dynamodb_table` no backend S3 do Terraform e por que eles importam?"

Documente no `relatorio-kiro.md` por que dividir o problema em dois prompts menores deu respostas mais precisas do que pedir tudo de uma vez.
