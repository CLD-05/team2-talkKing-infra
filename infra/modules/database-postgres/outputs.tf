output "db_instance_identifier" {
  description = "RDS instance identifier."
  value       = aws_db_instance.this.identifier
}

output "db_endpoint" {
  description = "RDS endpoint host:port."
  value       = aws_db_instance.this.endpoint
}

output "db_address" {
  description = "RDS endpoint hostname."
  value       = aws_db_instance.this.address
}

output "db_port" {
  description = "RDS port."
  value       = aws_db_instance.this.port
}

output "db_name" {
  description = "Database name."
  value       = aws_db_instance.this.db_name
}

output "db_secret_arn" {
  description = "Secrets Manager ARN for AWS-managed master password."
  value       = try(aws_db_instance.this.master_user_secret[0].secret_arn, null)
}

output "security_group_id" {
  description = "RDS security group ID."
  value       = aws_security_group.this.id
}
