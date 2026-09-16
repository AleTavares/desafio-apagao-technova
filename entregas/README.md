# 📬 Entregas — Operação TechNova

Aqui você **registra** sua entrega do desafio. O seu código fica no **seu**
repositório (o fork); esta pasta recebe apenas um arquivo apontando para ele.

## Como entregar

1. Garanta que o CI do **seu fork** está **100% verde** e o `relatorio-kiro.md` preenchido.
2. Crie o arquivo `entregas/SEU-RA/entrega.md` (use o modelo em [`_MODELO/entrega.md`](./_MODELO/entrega.md)).
3. Preencha a linha **`REPO:`** com a URL pública do seu fork.
4. Abra um **Pull Request para este repositório** com o título:
   ```
   [Desafio Apagão] RA: SEU-RA - Seu Nome
   ```

## O que acontece ao abrir o PR

O workflow **`validar-entrega`** deste repositório dispara automaticamente:
clona o seu repositório, aplica os **verificadores oficiais** e roda as 8 fases
+ o relatório. Você vê o resultado nos **checks do PR**.

> Os verificadores usados são sempre os **oficiais deste repo** — alterar os
> `verificar.sh` no seu fork não afeta a correção da entrega (e reprova no CI do
> seu próprio fork pelo job de integridade).

## Formato do `entrega.md`

- **Uma** pasta por aluno: `entregas/SEU-RA/entrega.md`.
- A linha `REPO:` deve conter só a URL, no formato `https://github.com/USUARIO/REPOSITORIO`.
