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

- **Diagnóstico (o que estava quebrado):** A pasta `config/` tinha 5 problemas apontados pelo `verificar.sh`: (1) a senha real `SenhaSuperSecreta123` estava hardcoded em `database.yml`; (2) o arquivo não usava variável de ambiente; (3) o `app.env` apontava para `APP_ENV=producao` em vez de `desenvolvimento`; (4) não existia `config/.gitignore` protegendo arquivos sensíveis; (5) faltava o `config/CORRIGIDO.md` com a flag.
- **Como usei a IA (prompt/spec resumido):** Dividi o problema em pedaços pequenos, atacando um erro por vez em vez de pedir "conserte a fase 1". Primeiro pedi para a IA ler o README e o `verificar.sh` da fase para descobrir os critérios exatos; depois tratei cada checagem como tarefa isolada: trocar a senha por `${DB_PASSWORD}`, ajustar o `APP_ENV`, criar o `.gitignore` (ignorando `*.env`, `*.pem`, `secrets.*`) e criar o `CORRIGIDO.md` com a flag exata.
- **A IA errou ou alucinou em algo? O quê?:** Não errou na solução, mas errou na execução: tentou editar os arquivos via terminal (`sed`/`python` com heredoc) e falhou várias vezes por problemas de escape entre as camadas de shell (PowerShell -> WSL -> bash). Percebi pelos erros `unterminated` retornados e pela corrupção de acentos num momento (precisei restaurar o arquivo com `git checkout`). A correção foi mudar de abordagem para uma edição mais controlada.
- **Como validei a correção:** Rodei `bash scripts/verificar.sh 1`. As 5 checagens passaram (senha removida, usa variável de ambiente, `APP_ENV=desenvolvimento`, `.gitignore` ignora `*.env`, flag encontrada) e retornou `Fase 1 CONCLUÍDA!` (exit 0). Observação conceitual: num caso real, remover o segredo do arquivo não basta — ele continua no histórico do Git (exigiria `git filter-repo`) e a credencial precisaria ser rotacionada no banco.

### Fase 2 — Docker

- **Diagnóstico:** O `app/Dockerfile` tinha 6 erros propositais: (1) `FROM node:latest` (tag flutuante); (2) `COPY . .` antes do `npm install`, matando o cache de layers; (3) `COPY package-lock.json` de um arquivo que não existe na pasta `app/`, o que quebrava o build; (4) rodava como root (sem `USER`); (5) faltava `EXPOSE 3000`; (6) `CMD` apontava para `app.js` em vez de `server.js`.
- **Como usei a IA:** Primeiro pedi para a IA ler `package.json`, `server.js` e o `verificar.sh` para confirmar a dependência (express), a porta (3000) e o entrypoint (server.js), e os critérios de validação (build + non-root + `/flag`). Só depois reescrevi o Dockerfile atacando um problema por vez, em vez de aceitar uma reescrita às cegas.
- **A IA errou/alucinou?:** Dessa vez acertou a solução de primeira. Um ponto de atenção que validei manualmente: como não existe `package-lock.json`, `npm ci` falharia (ele exige o lock), então usei `npm install --production` com `COPY package*.json ./` — o curinga resolve a ausência do lock sem criar arquivo à toa. Também confirmei que o `USER node` deve vir depois do `npm install` (o install precisa de permissão de escrita em `/app`).
- **Como validei:** Rodei `bash scripts/verificar.sh 2`. As 3 checagens passaram: `Imagem buildou`, `Imagem roda como usuário não-root ('node')` e `Endpoint /flag respondeu com a flag correta` — `Fase 2 CONCLUÍDA!` (exit 0).

### Fase 3 — Docker Compose

- **Diagnóstico:** O `docker-compose.yml` tinha 5 problemas que impediam a API de conectar ao PostgreSQL: (1) API e Postgres em redes diferentes (`frontend` vs `backend`), sem se enxergarem; (2) faltava a env `DB_PASSWORD` no serviço `api`; (3) `DB_HOST=database`, um nome de serviço inexistente (o correto é `postgres`); (4) healthcheck usava `pg_ready`, comando que não existe (o correto é `pg_isready`); (5) `depends_on` na forma curta, que não espera o banco ficar saudável.
- **Como usei a IA:** Pedi para a IA ler o `README`, o `docker-compose.yml` (que lista os 5 problemas nos comentários) e o `server.js` para confirmar quais variáveis de ambiente a API realmente usa (`DB_HOST`, `DB_PORT`, `DB_NAME`, `DB_USER`, `DB_PASSWORD`) e que a rota `/flag` faz uma query real no banco. Tratei cada um dos 5 problemas como um item isolado antes de reescrever o arquivo.
- **A IA errou/alucinou?:** Não alucinou. Uma decisão de projeto: em vez de só mover os dois serviços para uma das redes existentes, unifiquei em uma única rede `technova-net`, que é a forma mais limpa de resolver o problema 1. Também confirmei a dependência entre os itens 4 e 5: o `condition: service_healthy` só funciona se o healthcheck (item 4) estiver correto.
- **Como validei:** Rodei `bash scripts/verificar.sh 3`, que sobe a stack de verdade com `docker compose up --build`. Resultado: `docker-compose.yml é válido`, `/flag respondeu com a flag correta (API conectada ao banco)` e `Fase 3 CONCLUÍDA!` (exit 0). A flag só aparece quando a query `SELECT 1` ao Postgres funciona, então o verde prova que a conexão está real.

### Fase 4 — Terraform / HCL

- **Diagnóstico:** O `main.tf` + `variables.tf` tinham 5 erros de HCL: (1) faltava o bloco `terraform { required_providers { ... } }` declarando o provider `local`; (2) a variável `ambiente` era usada mas não estava declarada em `variables.tf`; (3) o recurso `local_file` usava o argumento `conteudo` em vez de `content`; (4) a interpolação estava como `${var::ambiente}` (dois-pontos duplos) em vez de `${var.ambiente}`; (5) o `output` referenciava o atributo inexistente `caminho_do_arquivo` em vez de `filename`.
- **Como usei a IA:** Segui a abordagem que o próprio README sugere: usar a mensagem exata do `terraform validate` como spec. Pedi para a IA explicar o significado de cada erro (provider não declarado, variável ausente, argumento/atributo inválido) e corrigir uma linha por vez, confirmando que os nomes de argumento (`content`) e atributo (`filename`) são os que o provider `local` realmente expõe.
- **A IA errou/alucinou?:** Não alucinou. Ponto de atenção: escrevi o HCL já alinhado (os `=` dos argumentos) para que o `terraform fmt -check` passasse sem precisar de um segundo passo; caso contrário bastaria rodar `terraform fmt`. Também fixei a versão do provider (`~> 2.4`) em vez de deixar sem restrição.
- **Como validei:** Rodei `bash scripts/verificar.sh 4`. Passaram todas as etapas: `terraform init`, `terraform validate`, `fmt` (formatado), `terraform apply` e `Flag gerada em saida/flag.txt` — `Fase 4 CONCLUÍDA!` (exit 0). Esta fase usa o provider `local` (gera arquivo no disco), então roda sem nenhuma credencial AWS.

### Fase 5 — VPC / Rede / Segurança

- **Diagnóstico:** O `main.tf` da rede tinha duas falhas graves: (1) o Security Group do RDS expunha a porta 5432 para `0.0.0.0/0`, ou seja, o banco estava aberto para a internet inteira; (2) a route table pública não tinha a rota `0.0.0.0/0 -> Internet Gateway`, então a subnet pública não tinha conectividade com a internet.
- **Como usei a IA:** Pedi uma revisão de segurança direcionada (não genérica): por que `cidr_blocks = ["0.0.0.0/0"]` na 5432 é perigoso e como restringir o acesso apenas ao SG da aplicação. A IA explicou o conceito de menor privilégio em rede e indicou trocar `cidr_blocks` por `security_groups = [aws_security_group.api.id]`. Para a rota, confirmei a sintaxe do bloco `route` com `gateway_id` dentro da route table.
- **A IA errou/alucinou?:** Não alucinou. Validei manualmente com `grep` que não sobrou nenhum `0.0.0.0/0` no ingress da 5432 do SG do RDS (o `egress` continua aberto de propósito, o que é normal: restringimos a entrada, não a saída). Mantive o `0.0.0.0/0` apenas onde faz sentido: no ingress da API (porta 3000, serviço público) e na rota de saída para a internet.
- **Como validei:** Rodei `bash scripts/verificar.sh 5`. Resultado: `terraform validate` OK, `SG do RDS referencia o SG da API (menor privilégio)`, `Rota 0.0.0.0/0 -> Internet Gateway presente` e `Flag da Fase 5 encontrada` — `Fase 5 CONCLUÍDA!` (exit 0). Conceito aplicado: o banco só aceita conexões de quem está no SG da API; referenciar o grupo (e não um IP) é dinâmico e seguro, pois o IP da API pode mudar.

### Fase 6 — RDS + Remote State

- **Diagnóstico:** O `main.tf` tinha 5 problemas em dois assuntos distintos. Backend S3: (1) faltava `encrypt = true` e (2) faltava `dynamodb_table` para o state locking. RDS: (3) `publicly_accessible = true` (banco exposto), (4) `storage_encrypted = false` (sem encriptação) e (5) faltava `db_subnet_group_name` (banco deveria ficar em subnets privadas).
- **Como usei a IA:** Segui a dica do README e separei em DOIS prompts distintos: um só sobre o RDS (quais atributos garantem banco não-público e armazenamento encriptado) e outro só sobre o backend S3 (por que `encrypt` e `dynamodb_table` importam). Dividir em dois pedidos menores deu respostas mais precisas e focadas do que pedir "conserta o RDS e o backend" de uma vez — misturar os dois temas num prompt só aumenta a chance de a IA confundir atributos de contextos diferentes.
- **A IA errou/alucinou?:** Ponto importante que exigiu julgamento meu: o `verificar.sh` só exige que `db_subnet_group_name` exista, mas apontar para um subnet group inexistente faria o `terraform validate` falhar. Então não bastou adicionar a linha — criei os recursos de apoio (VPC + duas subnets privadas + `aws_db_subnet_group`) e referenciei o recurso real, para o atributo existir E o validate passar. Uma resposta superficial da IA (só adicionar a linha) teria quebrado o validate.
- **Como validei:** Rodei `bash scripts/verificar.sh 6`. As 7 checagens passaram: `terraform validate`, `encrypt = true`, `dynamodb_table`, `publicly_accessible = false`, `storage_encrypted = true`, `db_subnet_group_name` e `Flag da Fase 6 encontrada` — `Fase 6 CONCLUÍDA!` (exit 0). O validate roda com `-backend=false` no CI, então não precisa do bucket real. Conceitos: encriptar o state protege segredos em repouso; o lock no DynamoDB evita que dois `apply` concorrentes corrompam o state.

### Fase 7 — Módulos

- **Diagnóstico:** O `main.tf` da raiz violava o princípio DRY: tinha dois recursos `local_file` praticamente idênticos (um para `dev`, outro para `staging`), copiados e colados, variando apenas o nome do ambiente. Isso torna a manutenção frágil — mudar a lógica exige alterar em vários lugares.
- **Como usei a IA:** Pedi em etapas, como o README sugere: primeiro como transformar o recurso num módulo parametrizado por variável (estrutura de arquivos do módulo), depois como chamá-lo duas vezes no root com `nome = "dev"` e `nome = "staging"`. Criei `modules/ambiente/` com `variables.tf` (variável `nome`), `main.tf` (o `local_file` parametrizado) e `outputs.tf`.
- **A IA errou/alucinou?:** O ponto mais sutil foi `path.module` vs `path.root`. Uma resposta ingênua usaria `path.module`, o que geraria os arquivos DENTRO da pasta do módulo — mas o `verificar.sh` procura por `saida/dev.txt` e `saida/staging.txt` na raiz da fase. Usei `path.root` de propósito para os arquivos saírem na pasta de quem chama o módulo. Também garanti que o módulo não tem nada hardcoded de "dev"/"staging" (tudo vem da variável), então é reutilizável de verdade e não um copia-e-cola disfarçado.
- **Como validei:** Rodei `bash scripts/verificar.sh 7`. As 7 checagens passaram: módulo existe, root chama o módulo 2x, root sem `local_file` duplicado, `terraform init + apply`, `saida/dev.txt` e `saida/staging.txt` gerados com o conteúdo correto, e `Flag da Fase 7 encontrada` — `Fase 7 CONCLUÍDA!` (exit 0). Prova de reutilização: para adicionar um ambiente `prod`, bastaria mais uma chamada `module "prod" { nome = "prod" }`.

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
