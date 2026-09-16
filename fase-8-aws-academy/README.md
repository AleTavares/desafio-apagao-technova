# Fase 8 — AWS Academy: A Prova de Fogo Real 🔥☁️

## O Incidente

> "Consertar código é uma coisa. Mas eu só vou acreditar que a TechNova está de pé quando eu ver a infra **rodando de verdade na AWS**. Suba tudo no nosso AWS Academy Learner Lab, prove que funciona, capture a evidência e depois destrua para não gastar créditos." — CTO

Esta é a **única fase que exige executar de verdade** na AWS. Você vai reunir o que consertou nas fases anteriores (VPC segura, RDS privado, remote state) e **aplicar no AWS Academy Learner Lab**.

---

## ⚙️ Regras do AWS Academy Learner Lab

- **Credenciais temporárias:** pegue em **AWS Details → AWS CLI** e cole em `~/.aws/credentials` (inclui `aws_session_token`). Elas expiram (~4h).
- **Região:** sempre **us-east-1**.
- **NÃO crie IAM users/groups/roles.** Use a role pré-existente **`LabRole`** e o instance profile **`LabInstanceProfile`**.
- **Destrua tudo** com `terraform destroy` após capturar a evidência.

---

## Seu Objetivo

1. Monte um projeto Terraform (pode reusar o que você consertou nas Fases 5, 6 e 7) e **aplique no Learner Lab**: no mínimo uma **VPC** e um recurso que gere um **output verificável**.
2. Capture a **identidade real da conta** do Lab:
   ```bash
   aws sts get-caller-identity
   ```
3. Preencha o arquivo **`evidencia.md`** (modelo abaixo) com:
   - O **Account ID** (12 dígitos) retornado pelo `get-caller-identity`
   - O **ARN** retornado (que contém `LabRole` ou seu usuário do Lab)
   - Um **output do `terraform apply`** (ex: id da VPC criada — começa com `vpc-`)
   - A **flag** desta fase
4. **Destrua** a infra (`terraform destroy`) e confirme no `evidencia.md`.

---

## Critério da Flag ✅

O CI valida o **formato** da evidência em `evidencia.md` (não tem acesso às suas credenciais, então valida a estrutura da prova):

- [ ] Contém um **Account ID** com 12 dígitos (`\d{12}`)
- [ ] Contém um **ARN da AWS** (`arn:aws:...`) — evidência do `get-caller-identity`
- [ ] Contém um **ID de recurso real** criado (ex: `vpc-...`)
- [ ] Confirma que executou o **`terraform destroy`**
- [ ] Contém a flag:

```
FLAG{infra-real-no-learner-lab-e-destruida}
```

### Modelo do `evidencia.md`

```markdown
# Evidência de Execução — Fase 8 (AWS Academy)

## get-caller-identity
Account ID: 123456789012
ARN: arn:aws:sts::123456789012:assumed-role/LabRole/user

## Recurso criado (terraform output)
vpc_id: vpc-0abc123def4567890

## Destruição confirmada
terraform destroy executado com sucesso: SIM

## Flag
FLAG{infra-real-no-learner-lab-e-destruida}
```

> ⚠️ **Não commite credenciais.** A evidência é o Account ID, ARN e IDs de recurso — nunca a Access Key ou o Session Token.

---

## 💡 Dica de Uso da IA

Aqui a IA ajuda a **montar a infra e interpretar erros do Learner Lab**, que são específicos. Diga sempre o contexto:

> "Estou no AWS Academy Learner Lab. Não posso criar IAM roles. Como configuro o EC2 para usar a role pré-existente `LabRole` via `LabInstanceProfile` no Terraform?"

E ao aplicar:

> "Meu `terraform apply` falhou com este erro no Learner Lab: [cole o erro]. O que ele significa nesse ambiente restrito?"

No `relatorio-kiro.md`, descreva o que foi diferente entre o que a IA "acha" que dá para fazer na AWS e o que o Learner Lab **realmente permite** — essa é a lição central desta fase.
