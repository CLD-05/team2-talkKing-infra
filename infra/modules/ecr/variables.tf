variable "project" {
  description = "Project name used in tags."
  type        = string
}

variable "environment" {
  description = "Environment name used in tags."
  type        = string
}

variable "repositories" {
  description = "ECR repository names to create."
  type        = list(string)
}

variable "image_tag_mutability" {
  description = "ECR image tag mutability. Use IMMUTABLE with git SHA image tags."
  type        = string
  default     = "IMMUTABLE"
}

variable "max_image_count" {
  description = "Number of images to retain per repository."
  type        = number
  default     = 30
}

variable "tags" {
  description = "Additional tags applied to all resources."
  type        = map(string)
  default     = {}
}
