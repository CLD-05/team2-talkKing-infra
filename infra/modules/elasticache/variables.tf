variable "project" {
  description = "Project name used in resource names."
  type        = string
}

variable "environment" {
  description = "Environment name used in resource names."
  type        = string
}

variable "vpc_id" {
  description = "VPC ID."
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for Redis."
  type        = list(string)
}

variable "eks_node_security_group_id" {
  description = "EKS node security group ID allowed to access Redis."
  type        = string
}

variable "engine_version" {
  description = "Redis engine version."
  type        = string
  default     = "7.1"
}

variable "node_type" {
  description = "Redis node type."
  type        = string
  default     = "cache.t3.micro"
}

variable "port" {
  description = "Redis port."
  type        = number
  default     = 6379
}

variable "parameter_group_name" {
  description = "Redis parameter group name."
  type        = string
  default     = "default.redis7"
}

variable "num_cache_clusters" {
  description = "Number of cache nodes."
  type        = number
  default     = 1
}

variable "automatic_failover_enabled" {
  description = "Whether automatic failover is enabled."
  type        = bool
  default     = false
}

variable "multi_az_enabled" {
  description = "Whether Multi-AZ is enabled."
  type        = bool
  default     = false
}

variable "transit_encryption_enabled" {
  description = "Whether in-transit encryption is enabled."
  type        = bool
  default     = false
}

variable "snapshot_retention_limit" {
  description = "Number of days to retain Redis snapshots."
  type        = number
  default     = 0
}

variable "tags" {
  description = "Additional tags applied to all resources."
  type        = map(string)
  default     = {}
}
