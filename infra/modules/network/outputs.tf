output "vpc_id" {
  description = "VPC ID."
  value       = aws_vpc.this.id
}

output "vpc_cidr_block" {
  description = "VPC CIDR block."
  value       = aws_vpc.this.cidr_block
}

output "public_subnet_ids" {
  description = "Public subnet IDs."
  value       = values(aws_subnet.public)[*].id
}

output "private_subnet_ids" {
  description = "Private application subnet IDs."
  value       = values(aws_subnet.private)[*].id
}

output "database_subnet_ids" {
  description = "Database subnet IDs."
  value       = values(aws_subnet.database)[*].id
}

output "nat_gateway_public_ip" {
  description = "NAT Gateway public IP, when enabled."
  value       = var.enable_nat_gateway ? aws_eip.nat[0].public_ip : null
}
