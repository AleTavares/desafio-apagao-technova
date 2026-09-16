# Fase 5 — VPC / Rede / Segurança: O Banco Exposto 🔥

## O Incidente

> "A auditoria de segurança acabou de me ligar em pânico: **o banco de dados da TechNova está aberto para a internet inteira**. Qualquer um no mundo pode tentar se conectar na porta 5432. E, de quebra, a subnet pública não tem rota para a internet, então nem a API funciona. Conserta isso AGORA." — CTO

O `main.tf` desta pasta define a rede da TechNova (VPC, subnet, IGW, route table, Security Groups), mas com **duas falhas graves**.

---

## Seu Objetivo

Corrigir o `main.tf`:

1. **Fechar o banco:** o Security Group do RDS **não pode** ter `0.0.0.0/0` na porta 5432. Ele deve aceitar conexões **apenas do Security Group da API** — troque o `cidr_blocks` pela referência `security_groups = [aws_security_group.api.id]`.
2. **Restaurar a conectividade:** adicione a rota `0.0.0.0/0` → **Internet Gateway** na route table pública (recurso `aws_route` com `gateway_id = aws_internet_gateway.main.id`, ou um bloco `route` dentro da route table).

Depois de corrigir, crie o arquivo **`CORRIGIDO.md`** com a flag desta fase.

---

## Critério da Flag ✅

O CI valida (análise do código + `terraform validate`):

- [ ] `terraform init` + `terraform validate` **sem erros**
- [ ] O Security Group do RDS **NÃO** tem `0.0.0.0/0` na porta 5432
- [ ] O Security Group do RDS referencia o SG da API (`security_groups`)
- [ ] Existe uma rota `0.0.0.0/0` apontando para o Internet Gateway
- [ ] Existe o arquivo `CORRIGIDO.md` com a flag:

```
FLAG{rede-segura-banco-fechado-rota-ok}
```

> **Por que não aplica na AWS aqui?** A execução real fica para a **Fase 8** (Learner Lab). Esta fase foca no **design seguro** da rede, validado por análise estática + `terraform validate` — barato e sem consumir créditos.

---

## 💡 Dica de Uso da IA

Peça revisão de segurança direcionada, não genérica:

> "Neste Security Group de banco de dados, o ingress da porta 5432 está com `cidr_blocks = ["0.0.0.0/0"]`. Por que isso é inseguro e como eu restrinjo para aceitar apenas o Security Group da aplicação?"

E valide você mesmo com `grep` que não sobrou nenhum `0.0.0.0/0` perto da porta 5432. No `relatorio-kiro.md`, explique o conceito de **menor privilégio em rede** que você aplicou.
