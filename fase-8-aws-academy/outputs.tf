output "vpc_id" {
  description = "ID da VPC criada"
  value       = aws_vpc.main.id
}

output "subnet_id" {
  description = "ID da subnet pública"
  value       = aws_subnet.public.id
}

output "sg_api_id" {
  description = "ID do Security Group da API"
  value       = aws_security_group.api.id
}
