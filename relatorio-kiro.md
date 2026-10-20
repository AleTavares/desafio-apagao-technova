# 🤖 Relatório de Uso de IA — Operação TechNova

## Identificação

- **Aluno:** Nicolas de Jesus Silva
- **RA:** 6325171
- **Ferramenta(s) de IA utilizada(s):** Kiro (IDE AI-powered pela AWS)
- **Data de conclusão:** 02/10/2026

---

## Parte A — Estratégia Geral com a IA

### A.1 Como você dividiu o desafio para a IA não alucinar nem sobrecarregar?

Dividi o desafio rigorosamente **fase por fase**, aplicando o conceito de isolamento de contexto. Em vez de pedir a correção do projeto inteiro de uma vez (o que geraria respostas genéricas ou código inventado), apresentava o `README.md` da fase atual ao Kiro, pedia para interpretar a dor relatada e os erros propositais, e só então partir para o plano de ação e a execução.

A sessão de Vibe do Kiro foi usada para as fases exploratórias (1, 2 e 3), e a sessão de Spec para as fases mais estruturadas de Terraform (4, 5, 6 e 7), onde o fluxo de requirements → design → tasks do Kiro ajudou a manter o foco em um problema de cada vez.

### A.2 Qual foi seu "tamanho ideal de spec/prompt"?

O tamanho ideal foi o escopo de **uma fase por vez**. Eu enviava o `README.md` junto com os códigos-fonte da fase via `#File` no chat do Kiro e pedia para estruturar a resposta em três etapas:
1. Identificar a causa raiz dos erros;
2. Explicar a solução técnica de cada item;
3. Fornecer os trechos de código corrigidos e o comando de verificação.

**Exemplo de prompt eficiente:**
> *"Estou na Fase 3 (Docker Compose). O README relata 5 erros na comunicação da API com o banco Postgres. Aqui está o #File docker-compose.yml. Identifique cada um dos 5 erros, explique o motivo da quebra e me forneça o YAML corrigido junto com a explicação do healthcheck."*

### A.3 Como você usou o CI/CD como bússola junto com a IA?

Utilizei os scripts de validação (`scripts/verificar.sh X`) e as saídas do pipeline GitHub Actions como bússola de progressão. A cada fase corrigida, executava a verificação local. Se o resultado fosse `✅ OK`, o feedback servia como confirmação para avançar de fase e abrir a próxima especificação no Kiro.

O painel de **Autopilot** do Kiro foi especialmente útil nas fases de Terraform: ele aplicava os edits diretamente nos arquivos `.tf` e eu podia confirmar cada hunk no modo **Supervised** antes de aceitar a mudança, evitando que a IA sobrescrevesse algo correto.

---

## Parte B — Relato Fase por Fase

### Fase 1 — Git

- **Diagnóstico (o que estava quebrado):** Senha em texto puro exposta no `database.yml` e ausência de arquivo `.gitignore` para mascarar variáveis de ambiente.
- **Como usei o Kiro:** Abri uma sessão de Vibe e usei `#File fase-1-git/config/database.yml` para contextualizar o Kiro. Pedi para isolar o segredo em variável de ambiente `APP_ENV` no YAML e configurar o `.gitignore` para arquivos `.env`. O Kiro editou os arquivos diretamente via ferramenta `str_replace`.
- **O Kiro errou ou alucinou em algo? O quê?:** Não. Seguiu a instrução direta de substituição da string pela variável de ambiente sem desvios.
- **Como validei a correção:** Execução do `bash scripts/verificar.sh 1` confirmando `✅ OK` e conferência manual de que nenhum segredo estava hardcoded no YAML.

### Fase 2 — Docker

- **Diagnóstico:** O container estava efetuando o build e executando o processo como usuário `root`, violando o princípio de menor privilégio.
- **Como usei o Kiro:** Usei `#File fase-2-docker/app/Dockerfile` como contexto e pedi a reestruturação garantindo a troca de permissões dos arquivos para o usuário sem privilégios `node`.
- **O Kiro errou/alucinou?:** Inicialmente esqueceu de passar a flag `--chown=node:node` na instrução `COPY`, o que mantinha os arquivos pertencendo ao root. Percebi ao ler o Dockerfile gerado e analisar o fluxo do build.
- **Como validei:** Rodei `docker build` manualmente e depois `bash scripts/verificar.sh 2`, confirmando que a imagem buildou e rodou como non-root com a flag de resposta ativa no endpoint `/flag`.

### Fase 3 — Docker Compose

- **Diagnóstico:** Redes separadas entre API e banco, `DB_HOST` errado (`database` em vez do nome correto do serviço), falta do `DB_PASSWORD`, healthcheck apontando para comando inexistente (`pg_ready`) e `depends_on` sem aguardar condição de saúde.
- **Como usei o Kiro:** Passei os 5 problemas listados no `README.md` via `#File` e pedi ao Kiro que apontasse as correções no `docker-compose.yml`. O modo Supervised foi usado para revisar cada mudança antes de aceitar.
- **O Kiro errou/alucinou?:** Não errou nesta fase.
- **Como validei:** `bash scripts/verificar.sh 3` (rodou `docker compose up`, esperou o postgres ficar `healthy` e validou a resposta no endpoint `http://localhost:3000/flag`).

### Fase 4 — Terraform / HCL

- **Diagnóstico:** Bloco `required_providers` ausente, variável `ambiente` não declarada, argumento `conteudo` em português (sem suporte no provider `local`), sintaxe de interpolação incorreta `${var::ambiente}` e atributo de output inexistente.
- **Como usei o Kiro:** Iniciei uma sessão de Spec no Kiro com os arquivos `main.tf` e `variables.tf` como contexto. O Kiro gerou um plano de tasks: corrigir sintaxe HCL2, declarar variável no `variables.tf` e ajustar o output. Executou cada task autonomamente em Autopilot.
- **O Kiro errou/alucinou?:** Não errou.
- **Como validei:** `terraform fmt`, `terraform validate` e `bash scripts/verificar.sh 4`, confirmando geração do arquivo `saida/flag.txt`.

### Fase 5 — VPC / Rede / Segurança

- **Diagnóstico:** Security Group do RDS exposto para `0.0.0.0/0` na porta 5432 (violação do princípio de menor privilégio) e ausência de rota de saída para a internet na tabela de roteamento da subnet pública.
- **Como usei o Kiro:** Usei `#File fase-5-rede-seguranca/main.tf` e pedi ao Kiro para ajustar o `ingress` do SG do RDS referenciando o ID do SG da API via `security_groups` e adicionar a rota default apontando para o Internet Gateway.
- **O Kiro errou/alucinou?:** Não errou nesta fase.
- **Como validei:** `bash scripts/verificar.sh 5` e conferência visual da regra de menor privilégio no `main.tf` gerado.

### Fase 6 — RDS + Remote State

- **Diagnóstico:** Backend S3 sem encriptação (`encrypt = true` faltando) e sem controle de concorrência (DynamoDB lock table ausente); RDS público (`publicly_accessible = true`), sem encriptação de armazenamento e fora das subnets privadas.
- **Como usei o Kiro:** Solicitei ao Kiro a inclusão das diretivas de segurança no bloco `backend "s3"` (encrypt, dynamodb_table) e nos parâmetros da instância `aws_db_instance` (publicly_accessible, storage_encrypted, db_subnet_group_name).
- **O Kiro errou/alucinou?:** Não errou.
- **Como validei:** `terraform validate -backend=false` e `bash scripts/verificar.sh 6`.

### Fase 7 — Módulos

- **Diagnóstico:** Violação do princípio DRY com declarações duplicadas de `resource "local_file"` para os ambientes `dev` e `staging` na raiz, sem usar módulos Terraform.
- **Como usei o Kiro:** Iniciei uma sessão de Spec com os arquivos da fase como contexto. O Kiro propôs: (1) criar `modules/ambiente/main.tf` com variáveis parametrizadas, (2) criar `modules/ambiente/variables.tf`, (3) refatorar o `main.tf` raiz para chamar o módulo duas vezes com `source = "./modules/ambiente"`.
- **O Kiro errou/alucinou?:** Não errou.
- **Como validei:** `bash scripts/verificar.sh 7` confirmando a criação dos arquivos `saida/dev.txt` e `saida/staging.txt` via módulo.

### Fase 8 — AWS Academy (execução real)

- **Diagnóstico / objetivo:** Provisionar a infraestrutura de forma real no AWS Academy Learner Lab respeitando as restrições do perfil `LabRole`, capturar evidências de execução e destruição da infraestrutura.
- **Como usei o Kiro:** Pedi ao Kiro a criação de uma declaração simples de VPC no `main.tf` compatível com o ambiente do Learner Lab e a estrutura do arquivo `evidencia.md`. O Kiro gerou o código e me alertou para não criar IAM roles via Terraform (restrição do Lab).
- **O Kiro errou/alucinou?:** Tentou inicialmente sugerir a criação de roles via Terraform, mas corrigi a instrução lembrando das restrições do Learner Lab para reutilizar a role pré-existente. O Kiro ajustou sem resistência.
- **Como validei:** `aws sts get-caller-identity` no terminal WSL, preenchimento das credenciais reais no `evidencia.md` e `bash scripts/verificar.sh 8`.

---

## Parte C — Reflexão Crítica

### C.1 Qual foi a pior alucinação do Kiro no desafio e como você a percebeu?

O Kiro não teve alucinações graves porque mantive a estratégia de condução por etapas pequenas com contexto preciso via `#File`. A principal desatenção foi na Fase 2 (Docker), onde ele sugeriu `USER node` mas esqueceu de ajustar a propriedade dos arquivos copiados com `--chown=node:node`. Percebi a falha ao revisar o Dockerfile gerado no modo Supervised — a instrução `COPY` ainda entregava arquivos como root, o que quebraria a execução.

### C.2 Em qual fase o Kiro MAIS ajudou? E em qual você teve que assumir o controle e resolver "no braço"?

- **Mais ajudou:** Fase 7 (Módulos), onde o fluxo de Spec do Kiro (requirements → design → tasks) acelerou muito a refatoração DRY do código Terraform e a criação da estrutura de módulo.
- **Assumi o controle:** Fase 2 (Docker) e Fase 8 (AWS Lab), onde precisei resolver na prática no terminal WSL os conflitos de containers antigos presos na porta 3000 e a formatação das credenciais temporárias no arquivo `~/.aws/credentials`. Esses problemas de ambiente local o Kiro não consegue resolver remotamente.

### C.3 O que você faria diferente na próxima vez que usar o Kiro para DevOps?

Usaria mais o modo **Supervised** para fases de Dockerfile e scripts Shell, onde erros de detalhe (como o `--chown`) são mais fáceis de escapar em modo Autopilot. Além disso, adicionaria uma etapa explícita de revisão de sintaxe como parte do prompt antes de aplicar qualquer mudança no terminal.

### C.4 Você conseguiria ter validado as respostas do Kiro se NÃO tivesse feito as aulas 01 a 07?

De forma alguma. Sem o conhecimento técnico das aulas 01 a 07, eu não saberia identificar se o `docker-compose` estava falhando por causa de rede, healthcheck ou dependência, nem entenderia conceitos cruciais como *state locking* com DynamoDB, regra de menor privilégio em Security Groups ou a diferença entre subnet pública e privada no contexto de RDS. O conhecimento das aulas é o que dá capacidade de avaliar se a resposta do Kiro é válida ou inventada — sem isso, eu estaria aceitando output cegamente.

---

## Checklist Final

- [x] Preenchi a estratégia geral (Parte A)
- [x] Relatei as 8 fases individualmente (Parte B)
- [x] Respondi a reflexão crítica (Parte C)
- [x] Meu CI está 100% verde (todas as fases + gate final)
- [x] Meu PR está aberto no repositório do desafio
