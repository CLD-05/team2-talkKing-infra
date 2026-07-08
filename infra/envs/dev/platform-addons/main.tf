module "addons" {
  source = "../../../modules/addons"

  aws_region                = var.aws_region
  cluster_name              = var.cluster_name
  vpc_id                    = var.vpc_id
  alb_controller_role_arn   = var.alb_controller_role_arn
  external_secrets_role_arn = var.external_secrets_role_arn

  enable_metrics_server               = var.enable_metrics_server
  enable_aws_load_balancer_controller = var.enable_aws_load_balancer_controller
  enable_external_secrets             = var.enable_external_secrets
  enable_argocd                       = var.enable_argocd
  enable_prometheus_stack             = var.enable_prometheus_stack
}
