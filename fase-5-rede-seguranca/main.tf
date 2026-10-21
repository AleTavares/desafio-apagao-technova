# Fase 5 CORRIGIDA — rede segura e com conectividade.
# Correcoes aplicadas:
#   1. SG do RDS: porta 5432 NAO aceita mais 0.0.0.0/0.
#      Agora so aceita conexoes vindas do SG da API (menor privilegio).
#   2. Adicionada a rota 0.0.0.0/0 -> Internet Gateway na route table publica.
#
# Observacao: esta fase e validada por analise do codigo + terraform validate.
# NAO precisa aplicar na AWS aqui (a execucao real e a Fase 8).

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

  # (2) Rota para a internet: todo trafego externo sai pelo Internet Gateway.
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
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

  # (1) SEGURO: o banco so aceita conexoes vindas do SG da API,
  # nunca da internet aberta. Aplicacao do menor privilegio em rede.
  ingress {
    description     = "PostgreSQL somente a partir do SG da API"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.api.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "technova-rds-sg" }
}