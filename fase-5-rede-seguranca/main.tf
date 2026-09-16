# ⚠️ REDE/SEGURANÇA QUEBRADA (Fase 5)
# A infra de rede da TechNova está insegura e sem conectividade.
# Corrija os problemas de Security Group e roteamento.
#
# Problemas propositais (encontre e corrija):
#   1. O Security Group do BANCO (rds) expõe a porta 5432 para 0.0.0.0/0 (INTERNET INTEIRA!).
#      Isso é uma falha grave de segurança. O banco só deve aceitar conexões do
#      Security Group da API (use security_groups = [aws_security_group.api.id]).
#   2. Falta a ROTA para a internet: a route table pública precisa de uma rota
#      0.0.0.0/0 apontando para o Internet Gateway (aws_route com gateway_id).
#
# Observação: esta fase é validada por análise do código + terraform validate.
# NÃO precisa aplicar na AWS aqui (a execução real é a Fase 8).

terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region                      = "us-east-1"
  skip_credentials_validation = true
  skip_requesting_account_id  = true
  skip_metadata_api_check     = true
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags       = { Name = "technova-vpc" }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = "technova-igw" }
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  tags                    = { Name = "technova-public" }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = "technova-public-rt" }

  # ❌ FALTA a rota para a internet aqui (0.0.0.0/0 -> Internet Gateway)
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_security_group" "api" {
  name   = "technova-api-sg"
  vpc_id = aws_vpc.main.id

  ingress {
    description = "API"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "technova-api-sg" }
}

resource "aws_security_group" "rds" {
  name   = "technova-rds-sg"
  vpc_id = aws_vpc.main.id

  # ❌ INSEGURO: banco exposto para a internet inteira!
  ingress {
    description = "PostgreSQL"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "technova-rds-sg" }
}
