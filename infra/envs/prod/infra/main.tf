locals {
  cluster_name = "${var.project}-${var.environment}-cluster"
  common_tags = {
    Team = "team2"
  }
}

module "network" {
  source = "../../../modules/network"

  project               = var.project
  environment           = var.environment
  cluster_name          = local.cluster_name
  vpc_cidr              = var.vpc_cidr
  availability_zones    = var.availability_zones
  public_subnet_cidrs   = var.public_subnet_cidrs
  private_subnet_cidrs  = var.private_subnet_cidrs
  database_subnet_cidrs = var.database_subnet_cidrs
  enable_nat_gateway    = var.enable_nat_gateway
  tags                  = local.common_tags
}

module "ecr" {
  source = "../../../modules/ecr"

  project      = var.project
  environment  = var.environment
  repositories = var.ecr_repositories
  tags         = local.common_tags
}

module "bastion" {
  count  = var.enable_bastion ? 1 : 0
  source = "../../../modules/bastion"

  project           = var.project
  environment       = var.environment
  vpc_id            = module.network.vpc_id
  public_subnet_id  = module.network.public_subnet_ids[0]
  allowed_ssh_cidrs = var.allowed_ssh_cidrs
  key_name          = var.bastion_key_name
  tags              = local.common_tags
}

module "eks" {
  source = "../../../modules/eks"

  project                                = var.project
  environment                            = var.environment
  aws_region                             = var.aws_region
  cluster_name                           = local.cluster_name
  cluster_version                        = var.cluster_version
  vpc_id                                 = module.network.vpc_id
  private_subnet_ids                     = module.network.private_subnet_ids
  bastion_role_arn                       = var.enable_bastion ? module.bastion[0].role_arn : null
  enable_bastion_access_entry            = var.enable_bastion
  additional_access_entries              = var.additional_access_entries
  cluster_endpoint_public_access         = var.cluster_endpoint_public_access
  cluster_endpoint_public_access_cidrs   = var.cluster_endpoint_public_access_cidrs
  node_instance_types                    = var.node_instance_types
  node_min_size                          = var.node_min_size
  node_max_size                          = var.node_max_size
  node_desired_size                      = var.node_desired_size
  attach_load_balancer_controller_policy = var.attach_load_balancer_controller_policy
  load_balancer_controller_policy_arn    = var.load_balancer_controller_policy_arn
  tags                                   = local.common_tags
}

module "database" {
  source = "../../../modules/database"

  project                    = var.project
  environment                = var.environment
  vpc_id                     = module.network.vpc_id
  database_subnet_ids        = module.network.database_subnet_ids
  eks_node_security_group_id = module.eks.node_security_group_id
  additional_allowed_security_group_ids = distinct(
    var.db_additional_allowed_security_group_ids
  )
  instance_class      = var.db_instance_class
  db_name             = var.db_name
  multi_az            = true
  deletion_protection = var.db_deletion_protection
  skip_final_snapshot = var.db_skip_final_snapshot
  tags                = local.common_tags
}

module "alert_history_database" {
  source = "../../../modules/database-postgres"

  project     = var.project
  environment = var.environment

  vpc_id                     = module.network.vpc_id
  database_subnet_ids        = module.network.database_subnet_ids
  eks_node_security_group_id = module.eks.node_security_group_id

  additional_allowed_security_group_ids = distinct(
    var.db_additional_allowed_security_group_ids
  )

  engine                 = "postgres"
  engine_version         = var.alert_history_db_engine_version
  parameter_group_family = var.alert_history_db_parameter_group_family

  db_port = 5432

  db_name = var.alert_history_db_name

  master_username = var.alert_history_db_master_username

  instance_class = var.alert_history_db_instance_class

  deletion_protection = var.alert_history_db_deletion_protection
  skip_final_snapshot = var.alert_history_db_skip_final_snapshot

  tags = local.common_tags
}

module "elasticache" {
  source = "../../../modules/elasticache"

  project                    = var.project
  environment                = var.environment
  vpc_id                     = module.network.vpc_id
  private_subnet_ids         = module.network.private_subnet_ids
  eks_node_security_group_id = module.eks.node_security_group_id
  additional_allowed_security_group_ids = distinct(
    var.redis_additional_allowed_security_group_ids
  )
  node_type                  = var.redis_node_type
  num_cache_clusters         = 2
  automatic_failover_enabled = true
  multi_az_enabled           = true
  snapshot_retention_limit   = 7
  tags                       = local.common_tags
}

module "secrets" {
  source = "../../../modules/secrets"

  project     = var.project
  environment = var.environment
  parameters  = var.ssm_parameters
  tags        = local.common_tags
}

module "github_oidc" {
  source = "../../../modules/github_oidc"

  project             = var.project
  environment         = var.environment
  github_owner        = var.github_owner
  github_repositories = var.github_repositories
  github_ref_pattern  = var.github_ref_pattern
  managed_policy_arns = var.github_actions_managed_policy_arns
  tags                = local.common_tags
}
