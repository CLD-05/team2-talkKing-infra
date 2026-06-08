variable "project" {
  description = "Project name used in resource names."
  type        = string
}

variable "environment" {
  description = "Environment name used in resource names."
  type        = string
}

variable "github_owner" {
  description = "GitHub organization or username."
  type        = string
}

variable "github_repositories" {
  description = "Repository names allowed to assume the role."
  type        = list(string)
}

variable "github_ref_pattern" {
  description = "GitHub OIDC subject suffix. Example: ref:refs/heads/dev or *."
  type        = string
  default     = "*"
}

variable "managed_policy_arns" {
  description = "Managed IAM policy ARNs attached to the GitHub Actions role."
  type        = list(string)
  default     = ["arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"]
}

variable "permissions_boundary_arn" {
  description = "Permissions boundary ARN required for IAM roles."
  type        = string
  default     = "arn:aws:iam::495599735720:policy/TeamRuntimeBoundary"
}

variable "tags" {
  description = "Additional tags applied to all resources."
  type        = map(string)
  default     = {}
}
