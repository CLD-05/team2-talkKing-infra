variable "project" {
  description = "Project name used in parameter paths."
  type        = string
}

variable "environment" {
  description = "Environment name used in parameter paths."
  type        = string
}

variable "parameters" {
  description = "SSM parameters to create."
  type = map(object({
    value       = string
    description = optional(string, "")
    secure      = optional(bool, true)
  }))
  default = {}
}

variable "tags" {
  description = "Additional tags applied to all resources."
  type        = map(string)
  default     = {}
}
