variable "project" {
  description = "Project name used in tags."
  type        = string
}

variable "environment" {
  description = "Environment name used in tags."
  type        = string
}

variable "bucket_name" {
  description = "S3 bucket name."
  type        = string
}

variable "enable_versioning" {
  description = "Whether bucket versioning is enabled."
  type        = bool
  default     = true
}

variable "tags" {
  description = "Additional tags applied to all resources."
  type        = map(string)
  default     = {}
}
