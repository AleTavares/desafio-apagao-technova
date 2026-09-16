# Fase 7 — Módulos: Fim do Copia-e-Cola 🧩

## O Incidente

> "Descobri por que a manutenção é um inferno: o time **copia e cola** o mesmo código Terraform para cada ambiente. Dev e staging são blocos idênticos duplicados. Quando muda uma regra, tem que mudar em vários lugares e sempre esquecem um. Quero isso **modularizado** — um módulo, chamado várias vezes." — CTO

O `main.tf` desta pasta tem **dois recursos duplicados** (dev e staging) que precisam virar **um módulo reutilizável**.

---

## Seu Objetivo

Refatorar aplicando o princípio **DRY**:

1. Criar um **módulo** em `modules/ambiente/` com:
   - `variables.tf` — uma variável `nome` (string) para o nome do ambiente
   - `main.tf` — um `local_file` que gera `${path.root}/saida/<nome>.txt` com o conteúdo `ambiente=<nome>`
   - (opcional) `outputs.tf`
2. No `main.tf` da raiz, **remover os dois `resource "local_file"` duplicados** e substituí-los por **duas chamadas de módulo**:
   - `module "dev"` com `nome = "dev"`
   - `module "staging"` com `nome = "staging"`
3. Garantir que `terraform apply` gere `saida/dev.txt` e `saida/staging.txt`.

---

## Critério da Flag ✅

O CI valida:

- [ ] Existe o módulo em `modules/ambiente/` (com `main.tf` e `variables.tf`)
- [ ] O `main.tf` da raiz **usa `module "..."`** (pelo menos 2 chamadas)
- [ ] O `main.tf` da raiz **NÃO tem mais** os recursos `local_file` duplicados diretamente
- [ ] `terraform init` + `terraform apply` rodam sem erro
- [ ] São gerados `saida/dev.txt` (contendo `ambiente=dev`) e `saida/staging.txt` (contendo `ambiente=staging`)
- [ ] Existe `CORRIGIDO.md` com a flag:

```
FLAG{modulos-dry-reutilizaveis}
```

---

## 💡 Dica de Uso da IA

Módulos são um ótimo caso para a IA **gerar a estrutura**, mas você precisa entender a composição. Peça em etapas:

> "Como transformo este recurso `local_file` num módulo Terraform reutilizável que recebe o nome do ambiente por variável? Mostre a estrutura de arquivos do módulo."

Depois:

> "Como eu chamo esse módulo duas vezes no root, uma para 'dev' e outra para 'staging'?"

Valide rodando `terraform apply` e conferindo que os dois arquivos foram gerados. No `relatorio-kiro.md`, explique como você garantiu que o módulo ficou realmente reutilizável (e não um "copia-e-cola disfarçado").

### Testar localmente

```bash
terraform init
terraform apply -auto-approve
cat saida/dev.txt saida/staging.txt
```
