# 🤖 Relatório de Uso de IA — Operação TechNova

> **OBRIGATÓRIO.** Sem este relatório preenchido de forma consistente, o desafio **não é considerado concluído**, mesmo com o CI 100% verde.
>
> O objetivo é provar que **você pilotou a IA** — que soube dividir o problema, validar as respostas e não caiu em alucinações. Respostas genéricas, vagas ou copiadas invalidam a entrega.

---

## Identificação

- **Aluno:** Emilly Santos de Oliveira
- **RA:** 4023575
- **Ferramenta(s) de IA utilizada(s):** Kiro
- **Data de conclusão:** 12/10/2026

---

## Parte A — Estratégia Geral com a IA

### A.1 Como você dividiu o desafio para a IA não alucinar nem sobrecarregar?

Desde o início, optei por trabalhar fase por fase, sem pedir que a IA "consertasse tudo de uma vez". Antes de começar qualquer correção, pedi uma análise geral do desafio para ter uma visão do que estava quebrado em cada fase — isso me ajudou a estruturar perguntas mais precisas depois. A ideia de ir por partes é uma boa prática para usar a IA como copiloto: quando você joga tudo de uma vez, ela tende a misturar os contextos, perder o foco e acabar gerando correções incorretas ou incompletas. Indo fase por fase, eu mantinha o controle sobre o que estava sendo feito e conseguia validar cada passo antes de avançar.

### A.2 Qual foi seu "tamanho ideal de spec/prompt"?

O que funcionou melhor foi sempre fornecer o arquivo com problema junto com o contexto do que cada fase pedia e o que tinha sido estudado nas aulas. Depois de fornecer o arquivo, eu pedia primeiro uma análise — para entender o que estava errado e por quê — e só depois pedia a correção. Isso evitou que eu aplicasse correções "às cegas". Um exemplo que funcionou bem foi logo no início: pedir uma análise geral antes de tocar em qualquer arquivo, o que me deu um mapa do desafio e me ajudou a formular perguntas mais precisas para cada fase.

### A.3 Como você usou o CI/CD como bússola junto com a IA?

No começo, quando vi o pipeline rodando depois do primeiro push, fiquei em dúvida se era normal — era a primeira vez que acompanhava um CI rodar em tempo real. Assim que entendi o que cada job representava, o pipeline virou minha bússola: jobs verdes confirmavam que a correção tinha funcionado, e jobs vermelhos me diziam exatamente qual fase precisava de atenção. Com isso, conseguia direcionar os próximos prompts para o Kiro de forma muito mais precisa, em vez de ficar tentando adivinhar o que ainda estava quebrado.

---

## Parte B — Relato Fase por Fase

### Fase 1 — Git

- **Diagnóstico (o que estava quebrado):** Senha `SenhaSuperSecreta123` hardcoded no `config/database.yml`; `APP_ENV=producao` em vez de `desenvolvimento`; faltavam `config/.gitignore` e `config/CORRIGIDO.md`.
- **Como usei a IA:** Colei o conteúdo do `database.yml` e pedi ao Kiro que analisasse o arquivo identificando problemas de segurança e configuração. Após a análise, pedi a correção de cada ponto identificado.
- **A IA errou ou alucinou em algo? O quê?:** A IA acertou na primeira tentativa — o diagnóstico foi preciso e as correções aplicadas foram exatamente o que o verificador esperava.
- **Como validei a correção:** Rodei `bash fase-1-git/verificar.sh` — todos os 5 checks passaram. CI verde no GitHub Actions.

### Fase 2 — Docker

- **Diagnóstico:** Imagem base `node:latest` sem versão fixa; `COPY package-lock.json` de arquivo inexistente; ordem errada (COPY antes do install, quebrando cache); sem usuário não-root; sem `EXPOSE 3000`; `CMD` apontando para `app.js` em vez de `server.js`.
- **Como usei a IA:** Colei o Dockerfile inteiro e pedi análise de todos os problemas de uma vez. O Kiro identificou os 6 problemas e propôs o arquivo corrigido.
- **A IA errou/alucinou?:** O verificador retornou erro de "Docker não disponível" na primeira tentativa — identifiquei que o Docker Desktop não estava ativo. Após abrir o Docker Desktop e rodar novamente, tudo funcionou corretamente.
- **Como validei:** `bash fase-2-docker/verificar.sh` — build OK, usuário não-root confirmado, endpoint `/flag` respondeu corretamente.

### Fase 3 — Docker Compose

- **Diagnóstico:** API na rede `frontend` e Postgres na rede `backend` (redes separadas, sem comunicação); faltava `DB_PASSWORD` nas env vars da API; `DB_HOST=database` errado (deveria ser `postgres`); healthcheck usava `pg_ready` (inexistente) em vez de `pg_isready`; `depends_on` sem `condition: service_healthy`.
- **Como usei a IA:** Fui parte por parte, especialmente para entender o que estava acontecendo em cada problema. Preferi esse ritmo mais lento para realmente compreender cada correção — por exemplo, entender por que as redes separadas impediam a comunicação entre os containers, e o que o `condition: service_healthy` resolve na prática.
- **A IA errou/alucinou?:** A IA não errou, mas por ter ido parte por parte, algumas correções precisaram de mais de uma rodada de perguntas para que eu entendesse bem antes de aplicar.
- **Como validei:** `bash fase-3-compose/verificar.sh` — stack subiu, Postgres ficou healthy, `/flag` respondeu corretamente.

### Fase 4 — Terraform / HCL

- **Diagnóstico:** Faltava bloco `terraform { required_providers {} }`; variável `ambiente` comentada em `variables.tf`; argumento `conteudo` inexistente (correto: `content`); interpolação `${var::ambiente}` com sintaxe inválida (correto: `${var.ambiente}`); output referenciando `caminho_do_arquivo` inexistente (correto: `filename`).
- **Como usei a IA:** Colei os arquivos `.tf` para o Kiro analisar. Como os erros de sintaxe do HCL não eram familiares para mim (como o `${var::ambiente}`), pedi que a IA explicasse cada erro antes de corrigir — isso me ajudou a entender a diferença entre os problemas e não só aplicar o fix mecanicamente.
- **A IA errou/alucinou?:** As sugestões foram corretas. A IA explicou bem cada erro de sintaxe e as correções funcionaram na primeira tentativa de `terraform validate`.
- **Como validei:** `terraform fmt`, `terraform validate`, `terraform apply` — gerou `saida/flag.txt` com a flag correta. CI verde.

### Fase 5 — VPC / Rede / Segurança

- **Diagnóstico:** Security Group do RDS com `cidr_blocks = ["0.0.0.0/0"]` na porta 5432 (banco exposto para a internet); route table pública sem rota `0.0.0.0/0` para o Internet Gateway (sem conectividade).
- **Como usei a IA:** Colei os arquivos Terraform e pedi que o Kiro identificasse problemas de segurança. A IA me explicou o conceito de menor privilégio e por que expor a porta 5432 para `0.0.0.0/0` é perigoso — qualquer pessoa na internet poderia tentar conexão direta com o banco. Após entender o conceito, a rota faltando para o Internet Gateway ficou mais fácil de identificar também.
- **A IA errou/alucinou?:** Não errou. A explicação conceitual ajudou bastante a validar a correção, porque eu entendia o porquê da mudança.
- **Como validei:** `bash fase-5-rede-seguranca/verificar.sh` — `terraform validate` OK, SG do RDS sem `0.0.0.0/0`, rota para IGW presente. CI verde.

### Fase 6 — RDS + Remote State

- **Diagnóstico:** Backend S3 sem `encrypt = true` e sem `dynamodb_table`; RDS com `publicly_accessible = true`, `storage_encrypted = false` e sem `db_subnet_group_name`.
- **Como usei a IA:** Separei os dois assuntos em pedidos distintos — primeiro o backend remoto (S3 + DynamoDB), depois a configuração do RDS. Isso ajudou a entender melhor cada parte sem misturar os contextos.
- **A IA errou/alucinou?:** As correções funcionaram direto. Separar os pedidos foi uma boa decisão — evitou confusão entre os dois conjuntos de problemas.
- **Como validei:** `bash fase-6-rds-state/verificar.sh` — todos os 7 checks passaram. CI verde.

### Fase 7 — Módulos

- **Diagnóstico:** Dois blocos `resource "local_file"` idênticos duplicados para `dev` e `staging`, violando o princípio DRY. Sem módulo reutilizável.
- **Como usei a IA:** Pedi tudo de uma vez — mostrei o código duplicado e pedi que o Kiro propusesse a refatoração em módulo reutilizável com as duas chamadas. A estrutura gerada funcionou de primeira: módulo criado corretamente com as variáveis certas e as duas chamadas no root module.
- **A IA errou/alucinou?:** Não errou. A estrutura do módulo foi gerada corretamente e o `terraform validate` passou sem ajustes.
- **Como validei:** `bash fase-7-modulos/verificar.sh` — módulo criado, duas chamadas no root, `saida/dev.txt` e `saida/staging.txt` gerados corretamente. CI verde.

### Fase 8 — AWS Academy (execução real)

- **Diagnóstico / objetivo:** Pasta sem nenhum arquivo `.tf` — precisava criar a configuração Terraform, aplicar no Learner Lab, capturar evidências e destruir a infra.
- **Como usei a IA:** Ao pedir o `main.tf`, já mencionei as restrições do ambiente: usar `LabRole`/`LabInstanceProfile`, região `us-east-1`, credenciais temporárias e não criar IAM users/roles. O Kiro gerou a configuração respeitando essas restrições.
- **A IA errou/alucinou?:** Na primeira tentativa rodei `terraform apply` sem ter o `main.tf` criado ainda — erro `No configuration files`. Reconheci o problema rapidamente porque o mesmo tipo de erro havia aparecido nas fases anteriores: sem arquivo de configuração, o Terraform não tem o que executar. Após criar o arquivo, o apply funcionou corretamente.
- **Como validei:** `aws sts get-caller-identity` retornou Account ID `983671637735` e ARN com `voclabs`; `terraform output` retornou `vpc_id = vpc-097420a9daf97f8ee`; `terraform destroy` executado com sucesso. `bash fase-8-aws-academy/verificar.sh` — todos os checks passaram.

---

## Parte C — Reflexão Crítica

### C.1 Qual foi a pior alucinação da IA no desafio e como você a percebeu?

O momento mais confuso não foi uma alucinação da IA em si, mas a dificuldade de organizar o fluxo de trabalho — especialmente na hora de preparar e enviar os arquivos para o repositório, configurar as credenciais da AWS e entender a ordem certa para rodar `terraform init` e `terraform apply`. Nesses momentos, a IA às vezes assumia que eu já tinha feito etapas que ainda não tinham sido feitas, o que gerava erros de contexto. Percebi isso quando os comandos sugeridos falhavam por dependências que ainda não estavam satisfeitas — aprendi a verificar o estado atual antes de executar qualquer sugestão.

### C.2 Em qual fase a IA MAIS ajudou? E em qual você teve que assumir o controle e resolver "no braço"?

A IA ajudou mais na estruturação geral do desafio desde o início — ter pedido uma visão geral me deu um mapa de onde eu estava e para onde precisava ir. Isso foi fundamental para não me perder entre as 8 fases. Já o controle mais manual foi necessário nas partes de execução: fazer os commits corretamente, organizar o push de cada fase para o repositório, e executar a sequência de comandos do Terraform (`init`, `apply`, `destroy`) na Fase 8. Esses passos dependiam de ação direta no terminal e de entender o estado atual do ambiente — a IA podia sugerir, mas quem precisava executar e verificar era eu.

### C.3 O que você faria diferente na próxima vez que usar IA para DevOps?

Da próxima vez, antes de pedir qualquer correção, eu descreveria melhor o estado atual do ambiente — por exemplo, informar se o Docker está rodando, se as credenciais já estão configuradas, se o `terraform init` já foi feito. Muitos erros que encontrei vieram de a IA assumir um estado que não era o real. Também separaria ainda mais os pedidos nas fases mais complexas, como a 3 e a 8, para não misturar contextos diferentes no mesmo prompt.

### C.4 Você conseguiria ter validado as respostas da IA se NÃO tivesse feito as aulas 01 a 07?

Não conseguiria. Os pequenos detalhes são justamente o que diferencia uma correção certa de uma errada — e sem o conhecimento das aulas, eu não teria como saber se o que a IA sugeriu estava correto. Por exemplo: sem entender o que é um Security Group, não saberia avaliar se remover o `0.0.0.0/0` na Fase 5 era suficiente ou se havia outros problemas. Sem saber como funcionam Docker layers, não saberia dizer se a ordem do `COPY` e `RUN` no Dockerfile estava certa. Sem as aulas, cada correção da IA seria um obstáculo — eu aplicaria sem entender e não saberia identificar quando ela errasse.

---

## Checklist Final

- [x] Preenchi a estratégia geral (Parte A)
- [x] Relatei as 8 fases individualmente (Parte B)
- [x] Respondi a reflexão crítica (Parte C)
- [x] Meu CI está 100% verde (todas as fases + gate final)
- [ ] Meu PR está aberto no repositório do desafio

> **Lembre-se:** este relatório é o que diferencia "a IA fez por mim" de "eu usei a IA como copiloto". O mascote do Kiro é para quem pilota. 🦖
