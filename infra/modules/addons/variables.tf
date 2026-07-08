variable "aws_region" {
  description = "AWS region."
  type        = string
}

variable "cluster_name" {
  description = "EKS cluster name."
  type        = string
}

variable "vpc_id" {
  description = "VPC ID used by AWS Load Balancer Controller."
  type        = string
}

variable "alb_controller_role_arn" {
  description = "IRSA role ARN for AWS Load Balancer Controller."
  type        = string
}

variable "external_secrets_role_arn" {
  description = "IRSA role ARN for External Secrets Operator."
  type        = string
}

variable "enable_metrics_server" {
  type    = bool
  default = true
}

variable "enable_aws_load_balancer_controller" {
  type    = bool
  default = true
}

variable "enable_external_secrets" {
  type    = bool
  default = true
}

variable "enable_argocd" {
  type    = bool
  default = true
}

variable "enable_prometheus_stack" {
  type    = bool
  default = true
}
