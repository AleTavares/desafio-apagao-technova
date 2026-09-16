# ⚠️ RDS + REMOTE STATE QUEBRADOS (Fase 6)
# A camada de dados e a proteção do state estão mal configuradas.
# Corrija os problemas de RDS e do backend remoto.
#
# Problemas propositais (encontre e corrija):
#   BACKEND (bloco terraform > backend "s3"):
#     1. Falta "encrypt = true" (o state guarda segredos e precisa ser encriptado)
#     2. Falta "dynamodb_table" para o state locking (prevenir conflitos)
#   RDS (aws_db_instance):
#     3. "publicly_accessible = true" — o banco NÃO pode ser público
#     4. "storage_encrypted = false" — o armazenamento deve ser encriptado
#     5. Falta "db_subnet_group_name" — o RDS deve ficar nas subnets privadas
#
# Esta fase é validada por terraform validate + análise do código (não aplica na AWS).

terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket = "technova-terraform-state"
    key    = "fase6/terraform.tfstate"
    region = "us-east-1"
    # ❌ falta encrypt = true
    # ❌ falta dynamodb_table = "..."
  }
}

provider "aws" {
  region                      = "us-east-1"
  skip_credentials_validation = true
  skip_requesting_account_id  = true
  skip_metadata_api_check     = true
}

variable "db_password" {
  description = "Senha do banco"
  type        = string
  sensitive   = true
  default     = "TrocarEmProducao123"
}

resource "aws_db_instance" "technova" {
  identifier        = "technova-db"
  engine            = "postgres"
  engine_version    = "15"
  instance_class    = "db.t3.micro"
  allocated_storage = 20

  db_name  = "technova"
  username = "technova"
  password = var.db_password

  # ❌ banco exposto para a internet
  publicly_accessible = true

  # ❌ armazenamento sem encriptação
  storage_encrypted = false

  # ❌ falta db_subnet_group_name (banco deve ficar em subnets privadas)

  skip_final_snapshot = true

  tags = { Name = "technova-db" }
}
