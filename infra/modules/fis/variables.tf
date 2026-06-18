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

variable "tags" {
  type        = map(string)
  default     = {}
  description = "FIS 리소스에 부여할 공통 태그"
}
