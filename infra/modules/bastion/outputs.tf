output "instance_id" {
  description = "Bastion EC2 instance ID."
  value       = aws_instance.this.id
}

output "public_ip" {
  description = "Bastion public IP."
  value       = aws_instance.this.public_ip
}

output "security_group_id" {
  description = "Bastion security group ID."
  value       = aws_security_group.this.id
}

output "role_arn" {
  description = "Bastion IAM role ARN."
  value       = aws_iam_role.this.arn
}

output "role_name" {
  description = "Bastion IAM role name."
  value       = aws_iam_role.this.name
}
