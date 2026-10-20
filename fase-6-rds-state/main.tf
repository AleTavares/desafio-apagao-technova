terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = "technova-terraform-state"
    key            = "fase6/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "technova-terraform-locks"
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

  # ✅ CORRIGIDO: Banco privado sem exposição pública
  publicly_accessible = false

  # ✅ CORRIGIDO: Armazenamento encriptado em repouso
  storage_encrypted = true

  # ✅ CORRIGIDO: Alocado nas subnets privadas
  db_subnet_group_name = "technova-db-subnet-group"

  skip_final_snapshot = true

  tags = { Name = "technova-db" }
}