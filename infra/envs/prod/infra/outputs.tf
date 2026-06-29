output "vpc_id" {
  value = module.network.vpc_id
}

output "public_subnet_ids" {
  value = module.network.public_subnet_ids
}

output "private_subnet_ids" {
  value = module.network.private_subnet_ids
}

output "database_subnet_ids" {
  value = module.network.database_subnet_ids
}

output "cluster_name" {
  value = module.eks.cluster_name
}

output "cluster_endpoint" {
  value     = module.eks.cluster_endpoint
  sensitive = true
}

output "cluster_security_group_id" {
  value = module.eks.cluster_security_group_id
}

output "cluster_primary_security_group_id" {
  value = module.eks.cluster_primary_security_group_id
}

output "node_security_group_id" {
  value = module.eks.node_security_group_id
}

output "alb_controller_role_arn" {
  value = module.eks.alb_controller_role_arn
}

output "external_secrets_role_arn" {
  value = module.eks.external_secrets_role_arn
}

output "bastion_public_ip" {
  value = var.enable_bastion ? module.bastion[0].public_ip : null
}

output "ecr_repository_uris" {
  value = module.ecr.repository_uris
}

output "db_endpoint" {
  value = module.database.db_endpoint
}

output "db_secret_arn" {
  value = module.database.db_secret_arn
}

output "redis_primary_endpoint" {
  value = module.elasticache.primary_endpoint_address
}

output "github_actions_role_arn" {
  value = module.github_oidc.role_arn
}

output "alert_history_db_endpoint" {
  description = "Alert History PostgreSQL endpoint."
  value       = module.alert_history_database.db_endpoint
}

output "alert_history_db_secret_arn" {
  description = "Alert History PostgreSQL secret ARN."
  value       = module.alert_history_database.db_secret_arn
}

output "alert_history_db_secret_name" {
  description = "Alert History PostgreSQL secret name."
  value       = module.alert_history_database.db_secret_name
}

output "alert_history_db_managed_secret_arn" {
  description = "AWS-managed Alert History PostgreSQL master secret ARN."
  value       = module.alert_history_database.db_managed_secret_arn
}
