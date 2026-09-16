# 🧠 Contexto do Desafio — Operação TechNova: A Madrugada do Apagão

> Documento de **memória/design** do desafio. Serve para o professor (e para uma IA que abra este repositório) entenderem a arquitetura, as decisões e como manter/estender o desafio.
>
> ⚠️ **Este documento NÃO contém as soluções nem as flags.** O gabarito fica em `GABARITO.md` (ignorado pelo git — não vai para o repositório público).

---

## Visão Geral

Desafio do **primeiro bimestre** do curso de DevOps (Análise e Desenvolvimento de Sistemas — UniFAAT 2026.2), cobrindo os **Módulos 1 e 2** (Aulas 01 a 07).

- **Formato:** CTF híbrido — cada fase é um **cenário quebrado** ("incidente") que, ao ser consertado, libera uma **flag** (`FLAG{...}`).
- **Modelo de premiação:** **todos que completarem** ganham um **mascote do Kiro** (não é por velocidade).
- **Dificuldade:** alta, de propósito.
- **Prazo:** **28/10**.
- **IA obrigatória:** o aluno deve usar IA (Kiro recomendado) como copiloto e documentar no `relatorio-kiro.md`.

---

## Narrativa

"São 03h14 da manhã. A TechNova sofreu um apagão total após um deploy de sexta-feira à noite." A infra caiu em **8 camadas**. O aluno é o engenheiro de plantão e restaura camada por camada, do código à nuvem.

---

## As 8 Fases

Cada fase é uma pasta `fase-N-*/` com: um `README.md` (incidente + objetivo + critério da flag), os **arquivos quebrados** e um `verificar.sh` (retorna exit 0 quando a fase está resolvida, exit 1 quando ainda quebrada).

| # | Pasta | Tema (Aula) | Tipo de validação |
|---|-------|-------------|-------------------|
| 1 | `fase-1-git` | Git (Aula 01) | Análise estática (segredo/config/flag) |
| 2 | `fase-2-docker` | Docker (Aula 01) | `docker build` + inspeção non-root + `curl /flag` |
| 3 | `fase-3-compose` | Docker Compose (Aula 02) | `docker compose up` + `curl /flag` (API↔Postgres) |
| 4 | `fase-4-terraform` | Terraform/HCL (Aula 03) | provider `local`: init/validate/fmt/apply |
| 5 | `fase-5-rede-seguranca` | VPC/Rede/Segurança (Aulas 03-04) | provider AWS (skip creds) + análise estática |
| 6 | `fase-6-rds-state` | RDS + Remote State (Aula 05) | validate `-backend=false` + análise estática |
| 7 | `fase-7-modulos` | Módulos Terraform (Aula 06) | provider `local`: refatoração em módulo + apply |
| 8 | `fase-8-aws-academy` | Execução real (Aulas 03-07) | valida **formato** da evidência (`evidencia.md`) |

### Princípios de design das fases

- **Fases 1 a 7** validam **sem precisar de conta AWS** (usam provider `local` ou provider AWS com `skip_*` só para `validate`). Isso mantém o CI barato e rápido.
- **Fase 8** é a única que exige **execução real** no **AWS Academy Learner Lab**; o aluno cola uma **evidência** (`evidencia.md`) e o `verificar.sh` valida o **formato** (Account ID, ARN, ID de recurso, confirmação de destroy, flag) — o CI **não** tem as credenciais do aluno.
- Cada `verificar.sh` usa `BASH_SOURCE` para caminho relativo e emojis ✅/❌ para leitura fácil.
- **Análise estática de HCL:** sempre filtrar comentários (`grep -vE '^\s*#'`) antes de dar `grep` de checagem, senão instruções nos comentários geram falso positivo.

---

## Validação Automática (CI/CD)

- **No repositório do aluno:** `.github/workflows/validar-desafio.yml` roda **um job por fase** (com `setup-terraform` nas fases 4-7) + um job `relatorio-kiro` (checa o relatório) + um gate final `desafio-completo` que só passa com tudo verde.
- **Validador local:** `scripts/verificar.sh` roda todas as fases (ou uma específica, passando o número) e mostra um placar. O aluno usa antes de entregar.

---

## Fluxo de Entrega (modelo TF)

1. O aluno faz **fork** deste repositório, nomeado `desafio-apagao-technova-SEU-RA`, **público**.
2. Conserta as 8 fases e preenche o `relatorio-kiro.md`. O CI do fork dele (`validar-desafio.yml`) valida.
3. Registra a entrega com um **PR neste próprio repositório** (o modelo), criando `entregas/SEU-RA/entrega.md` com uma linha `REPO: <url do fork do aluno>`.
4. O workflow **`validar-entrega.yml`** deste repositório dispara no PR: clona o fork do aluno, aplica os verificadores **oficiais** (via `scripts/validar-entrega.sh`) e roda as 8 fases + relatório.
5. Título do PR: `[Desafio Apagão] RA: XXXXX - Nome`.

> **Nota de arquitetura:** o código fica no fork do aluno; este repositório recebe só o `entrega.md` e valida remotamente clonando o fork. Como a correção usa os verificadores **deste** repo (não os do fork), o aluno não consegue afrouxar a validação da entrega.
>
> ⚠️ **Este desafio é autocontido:** não depende de nenhum outro repositório (ex.: o de conteúdo das aulas). A entrega e a correção acontecem inteiramente aqui.

---

## O Relatório Kiro (`relatorio-kiro.md`) — Obrigatório

É **gate**: sem ele preenchido, o desafio não conta, mesmo com o CI verde. Cobra:
- Como o aluno **dividiu as specs/prompts** em pedaços pequenos para evitar **alucinação e sobrecarga** da IA
- Como **validou** cada correção (não aceitar cegamente o output da IA)
- O que a IA **errou** e como ele percebeu
- Relato **fase por fase** + reflexão crítica

---

## Como Manter / Estender

- **Adicionar uma fase:** crie `fase-N-tema/` com `README.md`, arquivos quebrados e `verificar.sh` (exit 0/1). Adicione um job no workflow do repo do desafio e a fase no array de `scripts/verificar.sh`.
- **Trocar uma flag:** atualize a flag no arquivo/serviço da fase **e** no `verificar.sh` correspondente **e** no `GABARITO.md`.
- **Testar uma fase:** rode `bash scripts/verificar.sh N`. Sempre teste os dois estados: quebrado (deve falhar) e resolvido (deve passar).
- **Ambiente de teste usado na criação:** Docker e Terraform v1.16 disponíveis; todas as fases foram testadas quebrado→falha / corrigido→passa.

---

## Referência Rápida de Arquivos

```
desafio-apagao-technova/
├── README.md                         # enunciado, narrativa, regras, entrega
├── relatorio-kiro.md                 # template obrigatório (uso da IA)
├── scripts/verificar.sh              # validador local com placar
├── .github/workflows/validar-desafio.yml  # CI do repo do aluno
├── docs/CONTEXTO-DESAFIO.md          # este documento (memória de design)
├── GABARITO.md                       # soluções + flags (IGNORADO pelo git)
└── fase-1-git/ ... fase-8-aws-academy/
```
