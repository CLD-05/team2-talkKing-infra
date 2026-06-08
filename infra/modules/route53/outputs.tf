output "record_fqdn" {
  description = "Created record FQDN."
  value       = var.create_alias_record ? aws_route53_record.alias[0].fqdn : null
}
