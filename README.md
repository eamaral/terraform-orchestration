# Terraform Orchestration - Fastfood Infraestrutura

Este repositório contém os scripts de automação responsáveis por **orquestrar o provisionamento e destruição completa da infraestrutura** do projeto Fastfood, utilizando múltiplos módulos Terraform separados.

---

## 🔧 Requisitos

- Terraform instalado (`>= 1.0`)
- AWS CLI configurado com credenciais válidas
- Permissões administrativas na conta AWS

---

## Clonando os módulos Terraform

Este repositório orquestra a infraestrutura com base em múltiplos módulos separados. Antes de rodar os scripts `apply-all.sh` e `destroy-all.sh`, clone os módulos abaixo no mesmo diretório raiz:

```bash
git clone https://github.com/eamaral/network-terraform.git
git clone https://github.com/eamaral/alb-terraform.git
git clone https://github.com/eamaral/cognito-terraform.git
git clone https://github.com/eamaral/ecs-terraform.git
git clone https://github.com/eamaral/db-terraform.git
git clone https://github.com/eamaral/api-gateway-terraform.git
```

Garanta que as pastas fiquem organizadas assim:

```
terraform-orchestration/
├── apply-all.sh
├── destroy-all.sh
├── network-terraform/
├── alb-terraform/
├── cognito-terraform/
├── ecs-terraform/
├── db-terraform/
├── api-gateway-terraform/
```


---

## 🚀 Como aplicar toda a infraestrutura

```bash
./apply-all.sh
```

Esse script:

- Aplica todos os módulos Terraform na ordem correta
- Extrai os outputs e injeta dinamicamente nos próximos módulos
- Gera a aplicação backend completamente funcional com URL da API pública

> Ao final, será exibido o link da API e o link da documentação Swagger.

---

## 💣 Como destruir toda a infraestrutura

```bash
./destroy-all.sh
```

Esse script destrói **todos os recursos criados**, garantindo que nenhum custo adicional permaneça.

---

## 📘 Observações

- Os arquivos `.terraform`, `.terraform.lock.hcl` e `terraform.tfstate` são regenerados automaticamente
- O backend da aplicação é publicado automaticamente via **GitHub Actions** (CI/CD)

---

## 🔒 Segurança

- Nenhuma variável sensível é hardcoded nos scripts
- A destruição é segura, pois os módulos estão protegidos contra execução acidental

---

## ✅ Status da Infraestrutura

✅ Infraestrutura testada com sucesso  
✅ API Gateway com VPC Link para ALB interno  
✅ Backend rodando em ECS Fargate  
✅ Banco RDS acessado via subnets privadas  
✅ CI/CD automatizado via GitHub Actions
