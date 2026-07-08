variable "aws_region" {
  type    = string
  default = "ap-northeast-2"
}

variable "cluster_name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "alb_controller_role_arn" {
  type = string
}

variable "external_secrets_role_arn" {
  type = string
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
