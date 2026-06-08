variable "project" {
  description = "Project name used in tags and IAM policy paths."
  type        = string
}

variable "environment" {
  description = "Environment name used in tags and IAM policy paths."
  type        = string
}

variable "aws_region" {
  description = "AWS region."
  type        = string
}

variable "cluster_name" {
  description = "EKS cluster name."
  type        = string
}

variable "cluster_version" {
  description = "Kubernetes version for EKS."
  type        = string
  default     = "1.35"
}

variable "vpc_id" {
  description = "VPC ID."
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for EKS nodes."
  type        = list(string)
}

variable "cluster_endpoint_public_access" {
  description = "Whether the EKS API endpoint is publicly reachable."
  type        = bool
  default     = true
}

variable "cluster_endpoint_public_access_cidrs" {
  description = "CIDRs allowed to reach the public EKS API endpoint."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "bastion_role_arn" {
  description = "Optional bastion IAM role ARN to grant cluster admin access."
  type        = string
  default     = null
}

variable "enable_bastion_access_entry" {
  description = "Whether to create an EKS access entry for the bastion role."
  type        = bool
  default     = true
}

variable "additional_access_entries" {
  description = "Additional EKS access entries."
  type        = any
  default     = {}
}

variable "node_instance_types" {
  description = "Managed node group instance types."
  type        = list(string)
  default     = ["t3.medium"]
}

variable "node_min_size" {
  description = "Managed node group minimum size."
  type        = number
  default     = 2
}

variable "node_max_size" {
  description = "Managed node group maximum size."
  type        = number
  default     = 4
}

variable "node_desired_size" {
  description = "Managed node group desired size."
  type        = number
  default     = 2
}

variable "node_disk_size" {
  description = "Managed node root disk size in GiB."
  type        = number
  default     = 30
}

variable "enable_ebs_csi_driver" {
  description = "Whether to install the EBS CSI Driver EKS addon."
  type        = bool
  default     = true
}

variable "ebs_csi_driver_addon_version" {
  description = "Optional EBS CSI addon version. Null lets AWS use the default."
  type        = string
  default     = null
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
