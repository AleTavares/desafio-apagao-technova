# Fase 6 CORRIGIDA — RDS privado/encriptado e state protegido.
# Correcoes aplicadas:
#   BACKEND:
#     1. encrypt = true (state encriptado em repouso)
#     2. dynamodb_table para state locking (evita applies concorrentes)
#   RDS:
#     3. publicly_accessible = false (banco nao exposto a internet)
#     4. storage_encrypted = true (armazenamento encriptado)
#     5. db_subnet_group_name presente (banco em subnets privadas)

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

# VPC e subnets privadas onde o banco vai viver (rede interna, sem acesso publico).
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags       = { Name = "technova-vpc" }
}

resource "aws_subnet" "private_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.11.0/24"
  availability_zone = "us-east-1a"
  tags              = { Name = "technova-private-a" }
}

resource "aws_subnet" "private_b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.12.0/24"
  availability_zone = "us-east-1b"
  tags              = { Name = "technova-private-b" }
}

# Subnet group do RDS: agrupa as subnets privadas para o banco.
resource "aws_db_subnet_group" "technova" {
  name       = "technova-db-subnet-group"
  subnet_ids = [aws_subnet.private_a.id, aws_subnet.private_b.id]
  tags       = { Name = "technova-db-subnet-group" }
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

  # (3) Banco NAO exposto a internet.
  publicly_accessible = false

  # (4) Armazenamento encriptado em repouso.
  storage_encrypted = true

  # (5) Banco nas subnets privadas via subnet group.
  db_subnet_group_name = aws_db_subnet_group.technova.name

  skip_final_snapshot = true

  tags = { Name = "technova-db" }
}