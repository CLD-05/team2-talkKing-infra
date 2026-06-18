variable "project" {
  type        = string
  description = "프로젝트 이름 (예: talkking)"
}

variable "environment" {
  type        = string
  description = "배포 환경 (예: dev, prod)"
}

variable "cluster_arn" {
  type        = string
  description = "장애를 주입할 대상 EKS 클러스터의 ARN"
}

variable "namespace" {
  type        = string
  default     = "talkking-dev"
  description = "장애를 주입할 쿠버네티스 네임스페이스"
}

variable "pod_selector" {
  type        = string
  description = "Kubernetes label selector for pods targeted by FIS experiments."
  default     = "app=chat"
}

variable "kubernetes_service_account" {
  type        = string
  description = "Kubernetes service account used by FIS EKS pod actions."
  default     = "fis-experiment"
}

variable "permissions_boundary_arn" {
  type        = string
  description = "Permissions boundary ARN required for IAM roles created by the team."
  default     = "arn:aws:iam::495599735720:policy/TeamRuntimeBoundary"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "FIS 리소스에 부여할 공통 태그"
}
