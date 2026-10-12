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
    Name = "technova-fase8-vpc"
  }
}

output "vpc_id" {
  value       = aws_vpc.technova.id
  description = "ID da VPC criada no Learner Lab"
}
