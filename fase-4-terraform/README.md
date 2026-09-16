# Fase 4 — Terraform / HCL: O Código que Não Compila ⚙️

## O Incidente

> "O time tentou aplicar a infra e o Terraform cuspiu um monte de erro de sintaxe. Nada roda. Preciso que pelo menos o `terraform validate` e o `terraform plan` passem limpos antes de chegarmos perto da AWS." — CTO

O código Terraform desta pasta (`main.tf` + `variables.tf`) está cheio de erros de HCL do deploy de sexta. **Esta fase não usa AWS** — usa o provider `local` (gera um arquivo no disco), então você pode rodar `plan`/`apply` sem credenciais.

---

## Seu Objetivo

Corrigir os arquivos até o `terraform validate` e o `terraform plan` **passarem sem erros**. Há 5 problemas plantados (veja os comentários no topo do `main.tf`):

1. Falta o bloco `terraform { required_providers { ... } }` declarando o provider **`local`**
2. A variável **`ambiente`** é usada mas não foi **declarada** (`variables.tf`)
3. O recurso `local_file` usa o argumento errado (**`conteudo`** → `content`)
4. Interpolação com sintaxe errada (**`${var::ambiente}`** → `${var.ambiente}`)
5. O `output` referencia um atributo **inexistente** (`caminho_do_arquivo`) — o atributo correto do `local_file` é `filename`

Além disso, o código deve estar **formatado** (`terraform fmt`).

---

## Critério da Flag ✅

O CI roda, nesta pasta:

- [ ] `terraform fmt -check` — código **formatado**
- [ ] `terraform init` — provider `local` baixado
- [ ] `terraform validate` — **sem erros**
- [ ] `terraform apply -auto-approve` — gera `saida/flag.txt`
- [ ] O arquivo `saida/flag.txt` contém:

```
FLAG{terraform-hcl-valido-e-plan-limpo}
```

---

## 💡 Dica de Uso da IA

O `terraform validate` te dá o erro **exato** (arquivo, linha, mensagem). Use isso como spec para a IA:

> "O `terraform validate` retornou: [cole o erro]. O que essa mensagem significa e como corrijo essa linha do HCL?"

Corrija **um erro por vez** e rode `validate` de novo — a mensagem seguinte aparece. É assim que se depura Terraform de verdade. Registre no `relatorio-kiro.md` como cada mensagem de erro virou uma correção.

### Testar localmente

```bash
terraform init
terraform fmt
terraform validate
terraform apply -auto-approve
cat saida/flag.txt
```
