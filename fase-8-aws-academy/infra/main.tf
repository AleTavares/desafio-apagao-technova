# Fase 8 — Infra minima para executar no AWS Academy Learner Lab.
# Cria apenas uma VPC (recurso barato) com um output verificavel (vpc_id).
# Regras do Lab: regiao us-east-1, NAO criar IAM roles, destruir apos a evidencia.

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
  region = "us-east-1"
}

resource "aws_vpc" "technova" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "technova-fase8"
  }
}

output "vpc_id" {
  description = "ID da VPC criada (usar na evidencia.md)"
  value       = aws_vpc.technova.id
}