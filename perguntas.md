# 🎓 Perguntas e Respostas — Banca 1 a 1

> Guia de estudo para a validação individual com o professor.
> Baseado nos critérios e exemplos citados no README do desafio.

---

## 🔐 Fase 1 — Git

**P: Remover a senha do arquivo resolve o problema de segurança?**

Não. O arquivo foi modificado mas a senha continua no histórico do Git. Qualquer pessoa que clonou o repositório antes ou que rode `git log -p` consegue ver o valor original. A solução completa exige duas ações: reescrever o histórico com `git filter-repo` para apagar o commit que continha a senha, e rotacionar a credencial no banco de dados — porque a senha já pode ter sido vista.

---

**P: O que é um `.gitignore` e por que ele não resolve o problema de um segredo já commitado?**

O `.gitignore` impede que arquivos sejam rastreados pelo Git daqui para frente. Ele não desfaz o passado — se o arquivo já foi commitado, ele já está no histórico. O `.gitignore` só protege arquivos que ainda não entraram no repositório.

---

**P: Por que usar `${DB_PASSWORD}` em vez da senha direta?**

Porque a senha vira uma referência a uma variável de ambiente que existe apenas na máquina ou no servidor onde a aplicação roda. O código pode ser público — a credencial fica privada, fora do repositório.

---

## 🐳 Fase 2 — Docker

**P: Por que não usar `node:latest` como imagem base?**

A tag `latest` é flutuante — ela aponta para versões diferentes dependendo de quando você faz o build. Isso quebra a reprodutibilidade: um build de hoje pode gerar uma imagem diferente de um build de amanhã. Com `node:20-alpine` o comportamento é previsível e auditável.

---

**P: Por que copiar `package*.json` antes do código e rodar o `npm install` em seguida?**

Docker constrói imagens em camadas e faz cache de cada uma. Se você copia o código inteiro primeiro e depois roda o install, qualquer mudança em qualquer arquivo do código invalida o cache do `npm install` — que é a etapa mais lenta. Separando as etapas, o cache do `npm install` só é invalidado quando o `package.json` muda, o que é muito menos frequente.

---

**P: Por que rodar como usuário não-root no container?**

Se um atacante explorar uma vulnerabilidade na aplicação e conseguir executar comandos dentro do container, o impacto é limitado pelas permissões do usuário que está rodando o processo. Root dentro do container tem acesso irrestrito ao sistema de arquivos e, dependendo da configuração, pode escalar privilégios para o host. O princípio é o menor privilégio: a aplicação só precisa de permissão para rodar na porta 3000, não de acesso administrativo.

---

## 🧱 Fase 3 — Docker Compose

**P: Por que containers em redes diferentes não se comunicam pelo nome do serviço?**

No Docker Compose, cada rede é um segmento isolado. O DNS interno do Docker só resolve nomes de serviços dentro da mesma rede. Se `api` está na rede `frontend` e `postgres` está na `backend`, eles são invisíveis um para o outro — como se estivessem em VLANs separadas.

---

**P: O que o `depends_on: condition: service_healthy` resolve que o `depends_on` simples não resolve?**

O `depends_on` simples garante apenas que o container do banco *iniciou*. O processo do PostgreSQL pode levar alguns segundos para estar pronto para aceitar conexões após o container subir. Com `condition: service_healthy`, o Docker segura o container da API até o healthcheck passar — ou seja, até o banco estar realmente pronto para receber queries.

---

**P: Por que `pg_isready` e não `pg_ready`?**

`pg_isready` é o binário real que vem com o PostgreSQL para verificar se o servidor está aceitando conexões. `pg_ready` simplesmente não existe — o healthcheck falharia em todo ciclo, o postgres nunca ficaria `healthy` e a API nunca subiria.

---

## ⚙️ Fase 4 — Terraform HCL

**P: Por que o bloco `required_providers` é obrigatório?**

O Terraform precisa saber de onde baixar cada provider. Sem `required_providers`, o `terraform init` não sabe que precisa instalar o provider `local` da HashiCorp. É também uma boa prática de segurança: você fixa a fonte (`hashicorp/local`) e a versão para evitar que uma atualização quebre seu código ou que um provider malicioso seja injetado.

---

**P: Qual a diferença entre `${var.ambiente}` e `${var::ambiente}`?**

`${var.ambiente}` é a sintaxe correta do HCL para referenciar uma variável. O ponto é o separador entre o namespace (`var`) e o atributo (`ambiente`). Dois-pontos duplos (`::`) não tem significado em HCL — é um erro de sintaxe que o `terraform validate` rejeita imediatamente.

---

**P: O que o `terraform fmt` faz e por que o CI verifica isso?**

`terraform fmt` formata o código HCL seguindo o estilo padrão da HashiCorp: indentação, alinhamento de atributos, espaçamento. O CI verifica porque código mal formatado é sinal de descuido e dificulta revisões. É o equivalente a um linter — não afeta o comportamento, mas afeta a legibilidade e a manutenibilidade.

---

## 🔥 Fase 5 — VPC / Segurança

**P: Por que expor a porta 5432 para `0.0.0.0/0` é perigoso?**

Significa que qualquer máquina na internet pode tentar se conectar ao banco de dados. O PostgreSQL ficaria exposto a ataques de força bruta, exploração de vulnerabilidades do protocolo e vazamento de dados. Banco de dados nunca deve ter endpoint público — deve ser acessível apenas de dentro da VPC, e idealmente só de recursos específicos.

---

**P: Qual a diferença entre usar `cidr_blocks` e `security_groups` no ingress de um Security Group?**

`cidr_blocks` libera um range de endereços IP — é estático. `security_groups` libera todos os recursos que pertencem a outro SG, independentemente do IP — é dinâmico. Usar `security_groups = [aws_security_group.api.id]` significa que só as instâncias com aquele SG específico podem conectar no banco. Se o IP da API mudar, a regra continua funcionando.

---

**P: Por que a subnet pública não tinha conectividade sem a `aws_route`?**

Uma route table sem rotas só conhece o tráfego local (`10.0.0.0/16`). Para que instâncias na subnet pública alcancem a internet — ou recebam tráfego dela — é preciso uma rota padrão `0.0.0.0/0` apontando para o Internet Gateway. Sem essa rota, o tráfego externo não sabe para onde ir e é descartado.

---

**P: O que são as três camadas de defesa do banco que foram aplicadas nas fases 5 e 6?**

1. **Route table sem rota pública** (fase 5) — o banco fica em subnet privada, sem rota para a internet.
2. **Security Group restrito** (fase 5) — a porta 5432 só aceita conexões do SG da API, não de qualquer IP.
3. **`publicly_accessible = false`** (fase 6) — impede que a AWS crie um endpoint DNS público para o RDS.

Cada camada resolve um vetor diferente. Remover qualquer uma deixa uma brecha.

---

## 💾 Fase 6 — RDS + Remote State

**P: O que acontece se dois `terraform apply` rodarem ao mesmo tempo sem o DynamoDB lock?**

Os dois leem o state atual, calculam o plano independentemente e tentam escrever o resultado. O segundo apply sobrescreve o primeiro, gerando um state inconsistente com a infraestrutura real. Isso pode resultar em recursos duplicados, recursos órfãos ou configurações incorretas que só aparecem no próximo apply. O lock com DynamoDB garante que apenas um apply roda por vez.

---

**P: Por que `storage_encrypted = true` no RDS não é suficiente sozinho?**

`storage_encrypted` protege os dados *em repouso* — se alguém roubar o disco físico da AWS, os dados são ilegíveis. Mas não impede que alguém se conecte ao banco pela rede. `publicly_accessible = false` protege os dados impedindo conexões de fora da VPC. São vetores de ataque completamente distintos — encriptação em repouso e controle de acesso em rede.

---

**P: Por que o state do Terraform precisa ser encriptado?**

O arquivo `.tfstate` contém em texto plano todos os atributos dos recursos criados, incluindo senhas, chaves de acesso e outros segredos que foram passados como variáveis. Se o state ficar num bucket S3 sem encriptação, qualquer pessoa com acesso ao bucket lê todas as credenciais da infraestrutura.

---

## 🧩 Fase 7 — Módulos

**P: Por que o código duplicado é um problema em infraestrutura?**

Quando você precisa mudar uma regra — por exemplo, adicionar uma tag, mudar uma porta ou atualizar uma versão — precisa fazer a mudança em todos os lugares onde o bloco foi copiado. É fácil esquecer um. O módulo centraliza a lógica: muda em um lugar, todos os ambientes refletem automaticamente. É o princípio DRY (Don't Repeat Yourself).

---

**P: O que torna um módulo Terraform realmente reutilizável?**

Um módulo reutilizável tem uma interface clara: variáveis de entrada (`variables.tf`) que parametrizam o comportamento, e opcionalmente outputs. A implementação é única e agnóstica ao contexto de quem chama. No módulo `ambiente`, quem chama só passa o `nome` — não precisa saber como o arquivo é gerado por dentro. Se amanhã precisar de um terceiro ambiente, basta adicionar uma chamada `module "producao"` sem tocar no módulo.

---

**P: Qual a diferença entre `path.module` e `path.root` dentro de um módulo?**

`path.module` aponta para o diretório do próprio módulo (`modules/ambiente/`). `path.root` aponta para o diretório raiz do projeto que chamou o módulo. Usamos `path.root` para gerar os arquivos em `saida/` na raiz do projeto, e não dentro da pasta do módulo.

---

## ☁️ Fase 8 — AWS Academy

**P: Por que não criar IAM users/roles no Learner Lab?**

O AWS Academy usa uma conta gerenciada com permissões restritas. A `LabRole` já existe com as permissões necessárias. Tentar criar IAM roles falha com erro de permissão, e mesmo que funcionasse, criaria recursos fora do escopo do lab que poderiam conflitar com outros alunos ou violar os termos de uso.

---

**P: Por que rodar `terraform destroy` após capturar a evidência?**

Os créditos do Learner Lab são limitados. Recursos como VPCs, RDS e instâncias EC2 continuam gerando custo enquanto existem, mesmo sem uso. Destruir após o lab é obrigatório para não desperdiçar créditos — e também um hábito importante de FinOps em ambientes reais.

---

**P: O que o `aws sts get-caller-identity` prova?**

Prova que você executou comandos com credenciais reais da AWS, não apenas simulou localmente. Retorna o Account ID, o User ID e o ARN da identidade autenticada — evidência de que a sessão do Learner Lab estava ativa e que os recursos foram criados naquela conta específica.

---

**P: Por que as credenciais do Learner Lab expiram em ~4 horas?**

São credenciais temporárias geradas pelo STS (Security Token Service) via `AssumeRole`. Credenciais temporárias com curta validade são mais seguras porque, mesmo que vazem, ficam inválidas rapidamente. É o modelo recomendado pela AWS em vez de credenciais de longa duração (Access Keys permanentes de IAM users).

---

## 🤖 Uso do Kiro

**P: Por que pedir "conserte tudo de uma vez" para a IA é uma má estratégia?**

A IA perde o contexto quando o problema é muito grande, tende a inventar soluções para problemas que não existem e não consegue validar o resultado de cada passo. Dividindo em pedaços pequenos — uma fase por vez, um erro por vez — o contexto fica pequeno, a resposta é mais precisa e é possível validar cada correção antes de seguir.

---

**P: Como você usou o CI como bússola junto com a IA?**

Após cada correção, rodei o `verificar.sh` local. Se passava, seguia para a próxima fase. Se falhava, o erro exato virava o contexto do próximo prompt — "o verificador retornou este erro, o que causou isso?". O CI forneceu diagnóstico objetivo, evitando que a IA tentasse adivinhar o problema sem evidência.

---

**P: Em que momento você teve que assumir o controle sem depender da IA?**

Na Fase 2, o verificador retornava `❌ /flag não retornou a flag esperada` mesmo com o Dockerfile correto. A IA não tinha visibilidade do estado do Docker na máquina — havia um container de outro projeto (`reservas-api`) ocupando a porta 3000. Precisei investigar com `docker ps` e `ss -tlnp` para identificar o conflito. A IA não errou no código — o problema era de ambiente, e só o conhecimento técnico permitiu fazer esse diagnóstico.

---

*Estude especialmente Fases 3 e 5 — são as que o professor citou como exemplo de pergunta de banca no README.*
