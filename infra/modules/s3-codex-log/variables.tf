variable "project" {
  type        = string
  description = "Project name used in tags."
}

variable "environment" {
  type        = string
  description = "Environment name used in tags."
}

variable "bucket_name" {
  type        = string
  description = "S3 bucket name."
}

variable "enable_versioning" {
  type        = bool
  default     = true
  description = "Whether bucket versioning is enabled."
}

variable "glacier_transition_days" {
  type        = number
  default     = 30
  description = "Days after which logs transition to Glacier."
}

variable "log_retention_days" {
  type        = number
  default     = 90
  description = "Days after which logs are permanently deleted."
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Additional tags applied to all resources."
}

variable "glacier_transition_days" {
  type        = number
  default     = 30
  description = "Days after which logs transition to Glacier."
}

variable "log_retention_days" {
  type        = number
  default     = 90
  description = "Days after which logs are permanently deleted."
}
