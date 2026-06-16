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

variable "database_subnet_ids" {
  description = "Database subnet IDs."
  type        = list(string)
}

variable "eks_node_security_group_id" {
  description = "EKS node security group ID allowed to access RDS."
  type        = string
}

variable "additional_allowed_security_group_ids" {
  description = "Additional source security group IDs allowed to access RDS."
  type        = list(string)
  default     = []
}

variable "engine" {
  description = "RDS engine."
  type        = string
  default     = "postgres"
}

variable "engine_version" {
  description = "RDS PostgreSQL engine version."
  type        = string
  default     = "16.9"
}

variable "parameter_group_family" {
  description = "Database parameter group family."
  type        = string
  default     = "postgres16"
}

variable "instance_class" {
  description = "RDS instance class."
  type        = string
  default     = "db.t3.micro"
}

variable "allocated_storage" {
  description = "Initial allocated storage in GiB."
  type        = number
  default     = 20
}

variable "max_allocated_storage" {
  description = "Maximum storage autoscaling size in GiB."
  type        = number
  default     = 100
}

variable "db_name" {
  description = "Initial database name."
  type        = string
  default     = "errorops"
}

variable "master_username" {
  description = "RDS master username."
  type        = string
  default     = "postgres"
}

variable "db_port" {
  description = "Database port."
  type        = number
  default     = 5432
}

variable "multi_az" {
  description = "Whether RDS should be Multi-AZ."
  type        = bool
  default     = false
}

variable "backup_retention_period" {
  description = "Backup retention period in days."
  type        = number
  default     = 7
}

variable "deletion_protection" {
  description = "Whether deletion protection is enabled. Recommend true for production."
  type        = bool
  default     = false
}

variable "skip_final_snapshot" {
  description = "Whether to skip final snapshot during deletion. Recommend false for production."
  type        = bool
  default     = true
}

variable "tags" {
  description = "Additional tags applied to all resources."
  type        = map(string)
  default     = {}
}
