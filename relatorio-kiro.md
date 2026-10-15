# 🤖 Relatório de Uso de IA — Operação TechNova

> **OBRIGATÓRIO.** Sem este relatório preenchido de forma consistente, o desafio **não é considerado concluído**, mesmo com o CI 100% verde.

---

## Identificação

- **Aluno:** Matheus Mantovani
- **RA:** 1120245
- **Ferramenta(s) de IA utilizada(s):** Kiro
- **Data de conclusão:** 2025-07-14

---

## Parte A — Estratégia Geral com a IA

### A.1 Como você dividiu o desafio para a IA não alucinar nem sobrecarregar?

Trabalhei fase por fase, nunca pedindo "conserte tudo de uma vez". Antes de cada fase, li o README completo para entender o problema e só então pedi ao Kiro que analisasse os arquivos daquela fase específica. Isso evitou que a IA misturasse contextos ou inventasse correções para problemas que não existiam.

Pedir "conserte o repositório inteiro" leva a erro porque a IA tenta resolver tudo ao mesmo tempo, perde o fio dos critérios específicos de cada fase e acaba gerando código que parece certo mas não passa no verificador. Dividir por fase manteve o contexto pequeno e as respostas precisas.

### A.2 Qual foi seu "tamanho ideal de spec/prompt"?

O fluxo que funcionou foi: ler o arquivo quebrado → identificar o problema → pedir ao Kiro que analisasse aquele arquivo específico com o contexto do erro. Por exemplo, na Fase 2 o prompt foi essencialmente "aqui está o Dockerfile com 6 problemas documentados nos comentários, corrija todos eles seguindo as boas práticas de Docker". Sempre forneci o arquivo completo como contexto.

Um exemplo de prompt que funcionou bem foi na Fase 3: em vez de pedir "conserte o compose", forneci o `docker-compose.yml` inteiro e disse "há 5 problemas listados nos comentários do arquivo, corrija cada um e explique o porquê". Isso funcionou porque o Kiro teve contexto suficiente (o arquivo) e uma tarefa delimitada (5 problemas específicos).

### A.3 Como você usou o CI/CD como bússola junto com a IA?

Após cada correção, rodei o `verificar.sh` local antes de qualquer commit. O resultado do verificador direcionava o próximo passo: se passava, seguia para a próxima fase; se falhava, o erro exato virava o contexto do próximo prompt para o Kiro. Por exemplo, na Fase 2 o verificador retornou `❌ /flag não retornou a flag esperada` — isso revelou que o problema não era o Dockerfile (que já buildava), mas um conflito de porta com outro container rodando na máquina (`reservas-api`). O CI funcionou como diagnóstico objetivo, não deixando a IA adivinhar.

---

## Parte B — Relato Fase por Fase

### Fase 1 — Git

- **Diagnóstico:** Três problemas no diretório `config/`: senha `SenhaSuperSecreta123` hardcoded no `database.yml`, `APP_ENV=producao` no `app.env`, e ausência de `.gitignore` protegendo arquivos sensíveis.
- **Como usei a IA:** Pedi ao Kiro que lesse os dois arquivos quebrados e aplicasse as correções descritas no README: substituir a senha por `${DB_PASSWORD}`, corrigir o `APP_ENV`, criar o `.gitignore` com os padrões `*.env`, `*.pem`, `secrets.*` e criar o `CORRIGIDO.md` com a flag exata.
- **A IA errou ou alucinou em algo?:** Não. As correções foram diretas e o verificador passou na primeira execução com 5/5.
- **Como validei:** Rodei `bash fase-1-git/verificar.sh` — todos os 5 checks verdes. Confirmei manualmente com `cat` que a senha não existia mais no arquivo e que o `APP_ENV` estava correto.

### Fase 2 — Docker

- **Diagnóstico:** Dockerfile com 6 problemas: imagem base `latest`, ordem errada de layers (COPY antes do install), COPY de `package-lock.json` inexistente, sem usuário não-root, sem `EXPOSE 3000`, CMD apontando para `app.js` em vez de `server.js`.
- **Como usei a IA:** Forneci o Dockerfile completo com os comentários originais e pedi ao Kiro que corrigisse os 6 problemas seguindo boas práticas de Docker (versão fixa, cache de layers, non-root user).
- **A IA errou ou alucinou em algo?:** Não no Dockerfile. Porém o verificador falhou na primeira execução com `❌ /flag não retornou a flag esperada` — o Kiro não tinha como saber que havia um container de outro projeto (`reservas-api`) ocupando a porta 3000 na minha máquina. Precisei diagnosticar isso eu mesmo com `docker ps` e parar o container antes de rodar o verificador novamente.
- **Como validei:** `docker inspect --format '{{.Config.User}}' technova-fase2-verify` para confirmar o usuário não-root, `curl http://localhost:3000/flag` para confirmar o endpoint, `verificar.sh` 3/3 verde.

### Fase 3 — Docker Compose

- **Diagnóstico:** 5 problemas no `docker-compose.yml`: api e postgres em redes diferentes (`frontend` e `backend`), `DB_PASSWORD` ausente no serviço api, `DB_HOST=database` apontando para nome de serviço inexistente, healthcheck usando `pg_ready` (inexistente) em vez de `pg_isready`, `depends_on` sem `condition: service_healthy`.
- **Como usei a IA:** Forneci o arquivo completo e pedi a correção dos 5 problemas. Expliquei que a flag só seria liberada quando a API conseguisse fazer uma query real no banco.
- **A IA errou ou alucinou em algo?:** Não. Todos os 5 problemas foram identificados e corrigidos corretamente. O Kiro entendeu a dependência entre eles (rede → hostname → senha → healthcheck → depends_on).
- **Como validei:** `docker compose config --quiet` para validar sintaxe, `docker compose ps` para confirmar postgres healthy, `curl http://localhost:3000/flag` retornando a flag, `verificar.sh` 3/3 verde.

### Fase 4 — Terraform / HCL

- **Diagnóstico:** 5 erros de HCL no `main.tf`: bloco `required_providers` ausente, variável `ambiente` usada mas não declarada no `variables.tf` (estava comentada), argumento `conteudo` em vez de `content`, interpolação `${var::ambiente}` com sintaxe inválida, output referenciando `caminho_do_arquivo` em vez de `filename`.
- **Como usei a IA:** Forneci os dois arquivos (`main.tf` e `variables.tf`) e pedi correção dos 5 erros listados nos comentários, incluindo formatação com `terraform fmt`.
- **A IA errou ou alucinou em algo?:** Não. Todos os erros foram corrigidos na primeira tentativa. O `terraform validate` passou limpo.
- **Como validei:** `terraform fmt -check`, `terraform validate`, `terraform apply -auto-approve`, `cat saida/flag.txt` confirmando o conteúdo correto. `verificar.sh` 5/5 verde.

### Fase 5 — VPC / Rede / Segurança

- **Diagnóstico:** Dois problemas no `main.tf`: Security Group do RDS com `cidr_blocks = ["0.0.0.0/0"]` na porta 5432 (banco exposto para a internet), e route table pública sem rota `0.0.0.0/0` para o Internet Gateway.
- **Como usei a IA:** Pedi ao Kiro que corrigisse os dois problemas: trocar o `cidr_blocks` por `security_groups = [aws_security_group.api.id]` no SG do RDS e adicionar o recurso `aws_route` com `gateway_id = aws_internet_gateway.main.id`.
- **A IA errou ou alucinou em algo?:** Não. A correção foi precisa e o `terraform validate` passou sem erros (usando `skip_credentials_validation` para não precisar de credenciais AWS reais).
- **Como validei:** `grep` no arquivo para confirmar ausência de `0.0.0.0/0` perto da porta 5432, `terraform validate`, `verificar.sh` 4/4 verde.

### Fase 6 — RDS + Remote State

- **Diagnóstico:** 5 problemas: backend S3 sem `encrypt = true` e sem `dynamodb_table`, RDS com `publicly_accessible = true`, `storage_encrypted = false`, e sem `db_subnet_group_name`.
- **Como usei a IA:** Dividi em dois contextos distintos como o README sugeria: primeiro pedi a correção do backend S3 (encrypt e locking), depois as correções do RDS (acesso público, encriptação, subnet group).
- **A IA errou ou alucinou em algo?:** Não. As correções foram aplicadas corretamente. O verificador usa `grep -vE '^\s*#'` para ignorar comentários, então confirmei que os valores corretos estavam fora de comentários.
- **Como validei:** `terraform validate -backend=false`, inspeção manual do arquivo para confirmar `publicly_accessible = false` e `storage_encrypted = true` fora de comentários, `verificar.sh` 7/7 verde.

### Fase 7 — Módulos

- **Diagnóstico:** `main.tf` com dois recursos `local_file` duplicados (dev e staging) violando o princípio DRY. A tarefa era refatorar em um módulo reutilizável em `modules/ambiente/`.
- **Como usei a IA:** Pedi ao Kiro que criasse a estrutura do módulo (`modules/ambiente/main.tf` com o `local_file` parametrizado e `modules/ambiente/variables.tf` com a variável `nome`), e que refatorasse o `main.tf` da raiz para usar `module "dev"` e `module "staging"` removendo os recursos duplicados.
- **A IA errou ou alucinou em algo?:** Não. A estrutura do módulo foi criada corretamente com `${path.root}/saida/${var.nome}.txt` para gerar os arquivos na pasta correta relativa à raiz do projeto.
- **Como validei:** `terraform init`, `terraform apply -auto-approve`, `cat saida/dev.txt saida/staging.txt` confirmando `ambiente=dev` e `ambiente=staging`, `verificar.sh` 7/7 verde.

### Fase 8 — AWS Academy (execução real)

- **Diagnóstico / objetivo:** Aplicar infra real no AWS Academy Learner Lab: criar VPC, subnets, IGW, route table, route e security groups. Capturar evidência com `aws sts get-caller-identity` e IDs dos recursos criados.
- **Como usei a IA:** Pedi ao Kiro que montasse um `main.tf` completo reaproveitando a arquitetura corrigida nas fases 5 e 6: VPC com subnet pública, IGW, route table com rota para internet, SG da API e SG do banco restrito ao SG da API. O projeto foi configurado sem backend remoto para simplificar a execução no Lab.
- **A IA errou ou alucinou em algo?:** Houve um detalhe: o Kiro gerou o `main.tf` com formatação que precisou de `terraform fmt` antes do `fmt -check` passar. Foi uma questão menor de indentação, não uma alucinação. O `terraform validate` passou sem problemas.
- **Como validei:** `aws sts get-caller-identity` confirmou Account ID `585422413344` e ARN com `voclabs`. `terraform apply` criou 8 recursos (vpc, igw, subnet, route table, route, association, sg api, sg rds). `terraform output` retornou `vpc_id = vpc-04f7face960d0296e`, `subnet_id = subnet-08fff0b44a92b3972`, `sg_api_id = sg-0f58dbc7726b51fbe`. `terraform destroy` destruiu os 8 recursos. `verificar.sh` 5/5 verde.

---

## Parte C — Reflexão Crítica

### C.1 Qual foi a pior alucinação da IA no desafio e como você a percebeu?

A situação mais próxima de uma alucinação não foi da IA, mas um falso negativo do ambiente: na Fase 2, o verificador retornou `❌ /flag não retornou a flag esperada` mesmo com o Dockerfile correto. O Kiro não sabia da existência do container `reservas-api` ocupando a porta 3000 na minha máquina — era um contexto externo ao repositório. Percebi o problema ao analisar a mensagem de erro (`Cannot GET /flag` em vez de `connection refused`) e rodei `docker ps` para investigar. A IA não errou — o problema era de ambiente, não de código.

### C.2 Em qual fase a IA MAIS ajudou? E em qual você teve que assumir o controle?

A IA mais ajudou na **Fase 3 (Docker Compose)**: os 5 problemas tinham dependências entre si (rede errada impedia hostname, hostname errado impedia conexão, healthcheck errado impedia o depends_on de funcionar) e o Kiro conseguiu ver a cadeia completa e corrigi-la de forma coerente.

Tive que assumir o controle na **Fase 2**, especificamente no diagnóstico do conflito de porta. O verificador apontava falha no endpoint mas o Dockerfile estava correto — o Kiro não tinha visibilidade do estado do Docker na minha máquina. Precisei investigar com `docker ps`, `ss -tlnp` e entender que o problema era externo ao código.

### C.3 O que você faria diferente na próxima vez que usar IA para DevOps?

Verificaria o ambiente local antes de rodar os testes (containers rodando, portas ocupadas, conectividade de rede) para separar problemas de código de problemas de ambiente. Também documentaria os prompts exatos no momento em que os uso, não depois — fica mais preciso para o relatório e para repetir o processo.

### C.4 Você conseguiria ter validado as respostas da IA se NÃO tivesse feito as aulas 01 a 07?

Não. Sem as aulas, eu não saberia que `pg_ready` não existe e `pg_isready` é o correto (Fase 3), nem que `cidr_blocks` vs `security_groups` num Security Group são mecanismos completamente diferentes (Fase 5), nem que remover uma senha do arquivo não a remove do histórico Git (Fase 1). O conhecimento técnico é o que permite julgar se a resposta da IA faz sentido. Sem ele, qualquer resposta parece válida — e é aí que o engenheiro cai em alucinações sem perceber.

---

## Checklist Final

- [x] Preenchi a estratégia geral (Parte A)
- [x] Relatei as 8 fases individualmente (Parte B)
- [x] Respondi a reflexão crítica (Parte C)
- [x] Meu CI está 100% verde (todas as fases + gate final)
- [ ] Meu PR está aberto no repositório do desafio
