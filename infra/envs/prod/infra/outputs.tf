output "vpc_id" {
  value = module.network.vpc_id
}

output "cluster_name" {
  value = module.eks.cluster_name
}

output "cluster_endpoint" {
  value     = module.eks.cluster_endpoint
  sensitive = true
}

output "alb_controller_role_arn" {
  value = module.eks.alb_controller_role_arn
}

output "external_secrets_role_arn" {
  value = module.eks.external_secrets_role_arn
}

output "ecr_repository_uris" {
  value = module.ecr.repository_uris
}

output "db_endpoint" {
  value = module.database.db_endpoint
}

output "redis_primary_endpoint" {
  value = module.elasticache.primary_endpoint_address
}
