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

variable "enable_rabbitmq" {
  description = "운영 환경 RabbitMQ 헬름 애드온 배포 여부 스위치"
  type        = bool
  default     = false # 운영 환경은 더 보수적으로 false를 기본값으로 둡니다.
}
variable "rabbitmq_password" {
  description = "RabbitMQ 마스터 계정 비밀번호"
  type        = string
  sensitive   = true # 🔐 테라폼 콘솔 로그에 비밀번호가 평문으로 찍히는 것을 방지
}
