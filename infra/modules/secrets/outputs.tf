output "parameter_arns" {
  description = "Map of parameter key to ARN."
  value       = { for key, param in aws_ssm_parameter.this : key => param.arn }
}

output "parameter_names" {
  description = "Map of parameter key to full SSM name."
  value       = { for key, param in aws_ssm_parameter.this : key => param.name }
}
