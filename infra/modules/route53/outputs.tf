output "zone_id" {
  description = "Route 53 hosted zone ID."
  value       = aws_route53_zone.this.zone_id
}

output "name_servers" {
  description = "Name servers to register with the domain registrar."
  value       = aws_route53_zone.this.name_servers
}

output "record_fqdn" {
  description = "Created ALB alias record FQDN."
  value       = var.create_alias_record ? aws_route53_record.alias[0].fqdn : null
}

output "alb_dns_name" {
  description = "ALB DNS name selected by Kubernetes tags."
  value       = var.create_alias_record ? data.aws_lb.k8s_alb[0].dns_name : null
}
