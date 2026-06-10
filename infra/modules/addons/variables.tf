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

variable "enable_rabbitmq" {
  description = "EKS 클러스터 위에 헬름 기반 RabbitMQ 인프라를 배포할지 결정하는 스위치 변수입니다."
  type        = bool
  default     = false # 실수 배포 방지를 위해 기본값은 안전하게 꺼둠(false) 처리
}

variable "rabbitmq_password" {
  description = "RabbitMQ 마스터 계정 비밀번호"
  type        = string
  sensitive   = true # 🔐 테라폼 콘솔 로그에 비밀번호가 평문으로 찍히는 것을 방지
}
