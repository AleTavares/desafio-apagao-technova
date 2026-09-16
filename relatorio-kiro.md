# 🤖 Relatório de Uso de IA — Operação TechNova

> **OBRIGATÓRIO.** Sem este relatório preenchido de forma consistente, o desafio **não é considerado concluído**, mesmo com o CI 100% verde.
>
> O objetivo é provar que **você pilotou a IA** — que soube dividir o problema, validar as respostas e não caiu em alucinações. Respostas genéricas, vagas ou copiadas invalidam a entrega.

---

## Identificação

- **Aluno:**
- **RA:**
- **Ferramenta(s) de IA utilizada(s):** (ex: Kiro / Kiro Spec / ChatGPT / Claude / Copilot)
- **Data de conclusão:**

---

## Parte A — Estratégia Geral com a IA

### A.1 Como você dividiu o desafio para a IA não alucinar nem sobrecarregar?

> Explique sua estratégia de **quebrar o problema em pedaços pequenos**. Por que pedir "conserte o repositório inteiro" leva a erro, e como você evitou isso?

_(sua resposta)_

### A.2 Qual foi seu "tamanho ideal de spec/prompt"?

> Descreva como você formulou os pedidos: uma fase por vez? Um erro por vez? Deu contexto (logs, arquivos) antes de pedir a correção? Dê 1 exemplo de prompt bom que você usou e por que ele funcionou.

_(sua resposta)_

### A.3 Como você usou o CI/CD como bússola junto com a IA?

> Explique como o resultado do pipeline guiou seus próximos prompts para a IA.

_(sua resposta)_

---

## Parte B — Relato Fase por Fase

Para **cada uma das 8 fases**, preencha o bloco abaixo. Seja específico: qual era o bug, o que você pediu à IA, o que ela respondeu, **o que estava errado na resposta dela (se estava)**, e **como você validou** que a correção funcionou.

### Fase 1 — Git

- **Diagnóstico (o que estava quebrado):**
- **Como usei a IA (prompt/spec resumido):**
- **A IA errou ou alucinou em algo? O quê?:**
- **Como validei a correção:** (comando/evidência: ex. `git log`, scanner de segredo, CI verde)

### Fase 2 — Docker

- **Diagnóstico:**
- **Como usei a IA:**
- **A IA errou/alucinou?:**
- **Como validei:** (ex. `docker build`, `docker inspect` do usuário, tamanho da imagem)

### Fase 3 — Docker Compose

- **Diagnóstico:**
- **Como usei a IA:**
- **A IA errou/alucinou?:**
- **Como validei:** (ex. `docker compose up`, `curl /flag`, healthcheck)

### Fase 4 — Terraform / HCL

- **Diagnóstico:**
- **Como usei a IA:**
- **A IA errou/alucinou?:**
- **Como validei:** (ex. `terraform validate`, `terraform plan`)

### Fase 5 — VPC / Rede / Segurança

- **Diagnóstico:**
- **Como usei a IA:**
- **A IA errou/alucinou?:**
- **Como validei:** (ex. regra do SG, `plan`, checagem de exposição do banco)

### Fase 6 — RDS + Remote State

- **Diagnóstico:**
- **Como usei a IA:**
- **A IA errou/alucinou?:**
- **Como validei:** (ex. conexão ao banco, backend S3 + DynamoDB funcionando)

### Fase 7 — Módulos

- **Diagnóstico:**
- **Como usei a IA:**
- **A IA errou/alucinou?:**
- **Como validei:** (ex. `terraform validate` nos dois ambientes, composição correta)

### Fase 8 — AWS Academy (execução real)

- **Diagnóstico / objetivo:**
- **Como usei a IA (incluindo como instruiu a usar `LabRole`/`LabInstanceProfile`):**
- **A IA errou/alucinou?:**
- **Como validei:** (ex. `terraform output`, evidência assinada, API respondendo na nuvem)

---

## Parte C — Reflexão Crítica

### C.1 Qual foi a pior alucinação da IA no desafio e como você a percebeu?

_(sua resposta)_

### C.2 Em qual fase a IA MAIS ajudou? E em qual você teve que assumir o controle e resolver "no braço"?

_(sua resposta)_

### C.3 O que você faria diferente na próxima vez que usar IA para DevOps?

_(sua resposta)_

### C.4 Você conseguiria ter validado as respostas da IA se NÃO tivesse feito as aulas 01 a 07?

> Reflita sobre por que o conhecimento técnico é o que permite usar IA com segurança.

_(sua resposta)_

---

## Checklist Final

- [ ] Preenchi a estratégia geral (Parte A)
- [ ] Relatei as 8 fases individualmente (Parte B)
- [ ] Respondi a reflexão crítica (Parte C)
- [ ] Meu CI está 100% verde (todas as fases + gate final)
- [ ] Meu PR está aberto no repositório do desafio

> **Lembre-se:** este relatório é o que diferencia "a IA fez por mim" de "eu usei a IA como copiloto". O mascote do Kiro é para quem pilota. 🦖
