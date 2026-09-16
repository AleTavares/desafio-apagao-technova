# 🚨 Operação TechNova — A Madrugada do Apagão

> **Desafio DevOps — Primeiro Bimestre (Módulos 1 e 2)**
> **Análise e Desenvolvimento de Sistemas — UniFAAT 2026.2**
> **Professor:** Alexandre da Costa Tavares Jr

---

## 🏆 O Prêmio

**Todo aluno que completar o desafio inteiro (CI 100% verde + relatório Kiro válido) ganha um mascote do Kiro.**

Não é competição por velocidade nem por "melhor solução" — é um **desafio de superação**: quem chegar ao fim, ganha. O desafio é **difícil de propósito**. Espera-se que você use tudo que aprendeu no bimestre **e** o Kiro como copiloto.

**Prazo final:** **28/10/2026** (PR aberto e CI verde até essa data).

> ⚠️ **Ferramenta obrigatória: Kiro.** Este desafio deve ser resolvido usando o **Kiro** como IA copiloto. O uso de qualquer outra ferramenta de IA (ChatGPT, Claude, Copilot, Gemini, etc.) **desclassifica** a entrega. O `relatorio-kiro.md` deve comprovar o uso do Kiro.

---

## 📖 A Narrativa

> São **03h14 da manhã**. Seu celular não para de vibrar.

A TechNova sofreu um **apagão total**. Alguém fez um "deploy rápido" na sexta à noite, foi embora, e agora **nada funciona**: o repositório está bagunçado, a imagem Docker não builda, o ambiente local não sobe, a infraestrutura na AWS está quebrada e insegura, o banco não conecta e o state do Terraform está um caos.

O CTO Carlos Mendes te liga, desesperado:

> "Você é a única pessoa de plantão. Preciso da TechNova **de pé** de novo. Conserta camada por camada, do código à nuvem. E documenta como você fez — quero saber como você usou IA sem que ela te levasse pro buraco ainda mais fundo. Se você restaurar tudo, o prêmio é seu."

A infraestrutura caiu em **8 camadas**. Cada camada consertada libera uma **flag**. Restaure todas as 8, prove que a operação está de pé, e a TechNova (e o mascote) são seus.

---

## 🎯 Como Funciona

1. Faça um **fork** deste repositório:
   - Clique em **"Fork"** no canto superior direito
   - Nomeie como **`desafio-apagao-technova-SEU-RA`** e deixe-o **público**
2. Clone o seu repositório e conserte **cada fase** (pastas `fase-1-git/` até `fase-8-aws-academy/`)
3. Cada fase tem um `README.md` com o **incidente**, o **objetivo** e o **critério da flag**
4. A cada push, o **GitHub Actions** (o "juiz automático") valida suas correções na aba **Actions** do seu repositório
5. Preencha o **`relatorio-kiro.md`** (obrigatório — sem ele o desafio não conta)
6. Quando o CI do seu repositório ficar **100% verde** e o relatório estiver completo, **registre a entrega** (veja abaixo)

> **Validação automática (no seu repo):** o arquivo `.github/workflows/validar-desafio.yml` roda um job por fase e um **gate final** que só passa quando todas as fases passam. Acompanhe na aba **Actions**.

---

## 📬 Como Entregar

A entrega segue o mesmo modelo dos Trabalhos de Fixação (TF): o **código fica no seu repositório** (o fork), e você **registra a entrega** com um PR **neste repositório**, apontando para o seu.

1. Garanta que o CI do **seu fork** está **100% verde** e o `relatorio-kiro.md` preenchido
2. Neste repositório, crie o arquivo (use o modelo em [`entregas/_MODELO/entrega.md`](./entregas/_MODELO/entrega.md)):
   ```
   entregas/SEU-RA/entrega.md
   ```
3. No `entrega.md`, preencha a linha **`REPO:`** com a URL pública do seu fork
4. Abra um **Pull Request para este repositório** com o título:
   ```
   [Desafio Apagão] RA: SEU-RA - Seu Nome
   ```

> **Correção automática:** ao abrir o PR, o workflow **`validar-entrega`** deste repositório **clona o seu fork e roda os 8 verificadores oficiais + o relatório automaticamente**. Você vê o resultado nos checks do PR. Se ficar verde até **28/10/2026**, o mascote é seu. 🦖

---

## 🗺️ Mapa das 8 Fases

| # | Fase | Tema (Aula) | O que está quebrado |
|---|------|-------------|---------------------|
| 1 | `fase-1-git` | Git (Aula 01) | Segredo vazado no histórico, arquivo de config errado |
| 2 | `fase-2-docker` | Docker (Aula 01) | Dockerfile não builda, roda como root, imagem gigante |
| 3 | `fase-3-compose` | Docker Compose (Aula 02) | Stack não sobe: rede, healthcheck e env vars quebrados |
| 4 | `fase-4-terraform` | Terraform/IaC (Aula 03) | HCL inválido, provider e variáveis quebradas |
| 5 | `fase-5-rede-seguranca` | VPC/Rede/Segurança (Aulas 03-04) | Security Group expõe o banco, rota faltando |
| 6 | `fase-6-rds-state` | RDS + Remote State (Aula 05) | Conexão ao banco e backend remoto quebrados |
| 7 | `fase-7-modulos` | Módulos Terraform (Aula 06) | Código duplicado que precisa virar módulo reutilizável |
| 8 | `fase-8-aws-academy` | Execução real (Aulas 03-07) | Subir a infra de verdade no AWS Academy e provar |

> **Fases 1 a 7:** validadas 100% no CI (build, `terraform validate/plan`, testes, scanners). Não precisam de conta AWS.
> **Fase 8:** exige **executar** a infra no **AWS Academy Learner Lab** e colar a **evidência assinada** no repo. O CI valida o formato da evidência.

---

## 🤖 Regra de Ouro: Kiro Obrigatório e Documentado

O prêmio é o **mascote do Kiro** — e o **Kiro é a única ferramenta de IA permitida** neste desafio. Usar ChatGPT, Claude, Copilot, Gemini ou qualquer outra IA **desclassifica** a entrega. Você **deve** preencher o **`relatorio-kiro.md`** demonstrando:

- **Como usou o Kiro** para diagnosticar e consertar cada fase
- **Como validou** cada correção (não basta "o Kiro disse que era isso" — como você confirmou?)
- **Como dividiu as specs/prompts** em pedaços pequenos para **evitar alucinação e sobrecarga** da IA
- **O que o Kiro errou** e como você percebeu

> Um `relatorio-kiro.md` genérico, vago ou copiado invalida a conclusão do desafio, mesmo com o CI verde. A ideia é provar que **você pilotou o Kiro**, e não o contrário.

---

## 📋 Regras

1. **Individual.** Cada aluno resolve o desafio no seu próprio repositório.
2. **Todos que completarem ganham** — não é por velocidade.
3. **Kiro obrigatório e exclusivo.** O desafio deve ser resolvido com o **Kiro** como IA copiloto. Usar **qualquer outra** ferramenta de IA (ChatGPT, Claude, Copilot, Gemini, etc.) **desclassifica** a entrega.
4. **É permitido** consultar documentação oficial e o material das aulas.
5. **AWS Academy Learner Lab** para a Fase 8: use `LabRole`/`LabInstanceProfile`, região `us-east-1`, credenciais temporárias. **NÃO** crie IAM users/groups/roles. Rode `terraform destroy` após capturar a evidência.
6. **Nunca** commite segredos reais, `.tfstate`, `.terraform/` ou `*.pem`.
7. **Não altere a validação.** Os arquivos de validação — os `verificar.sh` de cada fase, o `scripts/verificar.sh` e o workflow `.github/workflows/validar-desafio.yml` — são **imutáveis**. O CI checa a integridade deles (job `integridade`) e **reprova o desafio** se qualquer um for modificado ou removido. Conserte o código das fases, nunca o "juiz".
8. **Prazo:** 28/10/2026.

---

## 🚀 Como Começar

```bash
# 1. Faça um fork deste repositório (botão "Fork"),
#    nomeando como desafio-apagao-technova-SEU-RA (público). Depois:
git clone https://github.com/SEU-USUARIO/desafio-apagao-technova-SEU-RA.git
cd desafio-apagao-technova-SEU-RA

# 2. Rode a verificação local para ver o estado inicial (tudo quebrado)
bash scripts/verificar.sh

# 3. Ataque uma fase por vez. Comece pela fase-1-git/README.md

# 4. Sempre que quiser, rode de novo para ver o que já passou
bash scripts/verificar.sh

# 5. Faça commits pequenos e descritivos (Conventional Commits)
git add .
git commit -m "fix(fase-1): remove segredo vazado do histórico"
git push

# 6. Acompanhe o CI na aba Actions do SEU repositório até ficar 100% verde.
# 7. Registre a entrega com um PR NESTE repositório (seção "Como Entregar").
```

---

## ✅ Critério de Conclusão

Você concluiu o desafio quando:

- [ ] O workflow **validar-desafio** está **verde em todas as 8 fases** no **seu fork**
- [ ] O **gate final** (`desafio-completo`) passou
- [ ] O **`relatorio-kiro.md`** está preenchido e demonstra uso crítico da IA
- [ ] Você abriu o **PR de entrega** com `entregas/SEU-RA/entrega.md` **neste repositório**
- [ ] O workflow **`validar-entrega`** validou seu fork (checks verdes no PR)

Cumpriu tudo até **28/10/2026**? **O mascote do Kiro é seu.** 🦖

---

## 🆘 Dicas de Sobrevivência

- **Leia o README de cada fase antes de mexer.** Ele diz exatamente qual é o critério da flag.
- **Divida para conquistar com a IA:** peça uma coisa por vez. "Conserte todo o repositório" gera alucinação. "Analise só este erro do `docker build` e explique a causa" funciona.
- **Sempre valide o que a IA sugere** com `terraform plan`, `docker build`, `curl`, testes — nunca aplique cego.
- **Use o CI como bússola:** cada job que fica verde é uma flag. Deixe o pipeline te guiar.
- **Fase 8 por último:** só suba a AWS depois que as fases de código estiverem sólidas, para economizar créditos do Lab.

---

*Boa madrugada, engenheiro(a). A TechNova conta com você. ☕*
