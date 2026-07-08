variable "project" {
  description = "Project name used in resource names."
  type        = string
}

variable "environment" {
  description = "Environment name used in resource names."
  type        = string
}

variable "vpc_id" {
  description = "VPC ID for the bastion security group."
  type        = string
}

variable "public_subnet_id" {
  description = "Public subnet ID where bastion is launched."
  type        = string
}

variable "allowed_ssh_cidrs" {
  description = "CIDR blocks allowed to SSH to the bastion."
  type        = list(string)
}

variable "key_name" {
  description = "Existing EC2 key pair name. Set null when using SSM Session Manager only."
  type        = string
  default     = null
}

variable "ami_id" {
  description = "Optional AMI ID override."
  type        = string
  default     = null
}

variable "instance_type" {
  description = "Bastion EC2 instance type."
  type        = string
  default     = "t3.micro"
}

variable "root_volume_size" {
  description = "Bastion root volume size in GiB."
  type        = number
  default     = 20
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
