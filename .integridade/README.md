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
estão no `HEAD` do aluno. Ele recupera as versões **originais** do **commit-base**
(primeiro commit do histórico) via `git show <base>:<arquivo>` e roda essa cópia
limpa contra os arquivos atuais do repositório.

## Uso local (aluno ou professor)

```bash
bash .integridade/verificar-integridade.sh
```

## Limites honestos desta camada (para o professor)

Como o desafio vive num **fork do aluno**, ele controla todos os arquivos. Esta
camada torna a adulteração **difícil e detectável**, mas não é uma trava absoluta:

- Se o aluno **reescrever/esmagar (squash) todo o histórico**, o "commit-base" passa
  a ser dele e ele poderia recompor o manifesto. Isso deixa rastro óbvio (histórico
  com pouquíssimos commits) e é facilmente flagrado na revisão.
- **Garantia real e à prova de adulteração** só é possível validando fora do controle
  do aluno — no **CI da disciplina** (`unifaat-2026-2-devops`), que clona o repo do
  aluno e roda os verificadores **oficiais** (não os do fork). Recomenda-se que a
  correção final da disciplina substitua os `verificar.sh` do aluno pelos originais
  antes de rodar.

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

Depois faça um novo commit para virar o novo "commit-base" de referência.
