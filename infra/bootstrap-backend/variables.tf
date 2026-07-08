variable "aws_region" {
  description = "AWS region."
  type        = string
  default     = "ap-northeast-2"
}

variable "project" {
  description = "Project name used in tags."
  type        = string
  default     = "team2-talkking"
}

variable "team" {
  description = "Team tag value required by IAM policy."
  type        = string
  default     = "team2"
}

variable "state_bucket_name" {
  description = "S3 bucket name for Terraform remote state."
  type        = string
}
