# 🔒 Camada de Integridade da Validação

Esta pasta garante que os **arquivos de validação do desafio não foram adulterados**
pelo aluno (os `verificar.sh` de cada fase, o `scripts/verificar.sh` e o workflow
`.github/workflows/validar-desafio.yml`).

## Arquivos

- **`manifest.sha256`** — hashes SHA-256 congelados pelo professor dos arquivos de
  validação. **Não editar.**
- **`verificar-integridade.sh`** — recalcula os hashes e compara com o manifesto.
  Retorna `exit 0` se tudo bate; `exit 1` se algo foi alterado/removido.

## Como está integrado no CI

O workflow tem um job **`integridade`** e o **gate final `desafio-completo` depende
dele**. Ou seja: mesmo que todas as 8 fases passem, se a integridade falhar, o
desafio é reprovado.

Para resistir a adulteração, o job **não confia** no script nem no manifesto que
estão no repositório do aluno. Ele **clona o repositório-modelo oficial** (o upstream
do professor, definido na variável `UPSTREAM` do workflow) e usa o
`verificar-integridade.sh` e o `manifest.sha256` **de lá** para checar os arquivos do
fork do aluno (via `RAIZ_OVERRIDE` apontando para o checkout do aluno). Como o aluno
não controla o upstream, essa referência é confiável.

## Uso local (aluno ou professor)

```bash
bash .integridade/verificar-integridade.sh
```

## Limites honestos desta camada (para o professor)

Como o desafio vive num **fork do aluno**, ele controla todos os arquivos. Esta
camada torna a adulteração **difícil e detectável**, mas não é uma trava absoluta:

- A checagem depende de o **upstream oficial estar acessível** (repositório público).
  Se o job não conseguir cloná-lo, ele falha de forma segura (reprova) em vez de passar.
- A checagem clona o **upstream oficial** definido em `UPSTREAM`. Se você renomear/mover
  o repositório-modelo, **atualize essa URL** no workflow, senão o job de integridade
  falha para todos os alunos.
- **Garantia máxima** é a **correção da entrega** (`validar-entrega.yml` +
  `scripts/validar-entrega.sh`): ao abrir o PR de entrega neste repositório, o CI
  clona o fork do aluno e roda os verificadores **oficiais deste repo** (não os do
  fork). Ou seja, mesmo que o aluno afrouxe algo no fork, a entrega é corrigida com
  os originais.

## Ao manter o desafio

Se você (professor) alterar **de propósito** algum `verificar.sh` ou o workflow,
**regenere o manifesto**:

```bash
{
  echo "# Manifesto de integridade — Operação TechNova"
  echo "# Gerado pelo professor. NÃO edite: o CI recalcula e compara."
  echo "# Qualquer alteração nos arquivos de validação abaixo REPROVA o desafio."
} > .integridade/manifest.sha256
for f in \
  fase-1-git/verificar.sh fase-2-docker/verificar.sh fase-3-compose/verificar.sh \
  fase-4-terraform/verificar.sh fase-5-rede-seguranca/verificar.sh \
  fase-6-rds-state/verificar.sh fase-7-modulos/verificar.sh \
  fase-8-aws-academy/verificar.sh .github/workflows/validar-desafio.yml \
  scripts/verificar.sh ; do
  sha256sum "$f"
done >> .integridade/manifest.sha256
```

Depois faça commit e push no **repositório-modelo oficial** (o upstream), pois é dele
que o CI de cada aluno baixa a referência.
