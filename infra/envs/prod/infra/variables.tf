variable "aws_region" {
  type    = string
  default = "ap-northeast-2"
}

variable "project" {
  type    = string
  default = "team2-talkking"
}

variable "environment" {
  type    = string
  default = "prod"
}

variable "vpc_cidr" {
  type    = string
  default = "10.10.0.0/16"
}

variable "availability_zones" {
  type    = list(string)
  default = ["ap-northeast-2a", "ap-northeast-2c"]
}

variable "public_subnet_cidrs" {
  type    = list(string)
  default = ["10.10.1.0/24", "10.10.2.0/24"]
}

variable "private_subnet_cidrs" {
  type    = list(string)
  default = ["10.10.11.0/24", "10.10.12.0/24"]
}

variable "database_subnet_cidrs" {
  type    = list(string)
  default = ["10.10.21.0/24", "10.10.22.0/24"]
}

variable "enable_nat_gateway" {
  type    = bool
  default = true
}

variable "ecr_repositories" {
  type = list(string)
  default = [
    "team2-talkking/chat-service",
    "team2-talkking/notification-service",
    "team2-talkking/ai-error-analyzer"
  ]
}

variable "allowed_ssh_cidrs" {
  type    = list(string)
  default = []
}

variable "bastion_key_name" {
  type    = string
  default = null
}

variable "cluster_version" {
  type    = string
  default = "1.35"
}

variable "cluster_endpoint_public_access" {
  type    = bool
  default = false
}

variable "cluster_endpoint_public_access_cidrs" {
  type    = list(string)
  default = []
}

variable "node_instance_types" {
  type    = list(string)
  default = ["t3.large"]
}

variable "node_min_size" {
  type    = number
  default = 2
}

variable "node_max_size" {
  type    = number
  default = 6
}

variable "node_desired_size" {
  type    = number
  default = 2
}

variable "db_instance_class" {
  type    = string
  default = "db.t3.small"
}

variable "db_name" {
  type    = string
  default = "talkking"
}

variable "db_additional_allowed_security_group_ids" {
  type    = list(string)
  default = []
}

variable "redis_node_type" {
  type    = string
  default = "cache.t3.small"
}

variable "redis_additional_allowed_security_group_ids" {
  type    = list(string)
  default = []
}

variable "github_owner" {
  type    = string
  default = "CLD-05"
}

variable "github_repositories" {
  type = list(string)
  default = [
    "team2-talkKing-app",
    "team2-talkKing-config",
    "team2-talkKing-infra"
  ]
}

variable "github_ref_pattern" {
  type    = string
  default = "ref:refs/heads/main"
}

variable "github_actions_managed_policy_arns" {
  type    = list(string)
  default = ["arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"]
}
