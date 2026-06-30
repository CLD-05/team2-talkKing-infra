variable "zone_name" {
  description = "Public Route 53 hosted zone name."
  type        = string
}

variable "record_name" {
  description = "DNS record name that points to the Kubernetes ALB."
  type        = string
}

variable "create_alias_record" {
  description = "Whether to create the ALB alias record."
  type        = bool
  default     = true
}

variable "cluster_name" {
  description = "EKS cluster name used by the AWS Load Balancer Controller tag."
  type        = string
}

variable "ingress_namespace" {
  description = "Kubernetes namespace containing the Ingress."
  type        = string
}

variable "ingress_name" {
  description = "Kubernetes Ingress name used to locate the ALB."
  type        = string
}

variable "tags" {
  description = "Tags applied to the hosted zone."
  type        = map(string)
  default     = {}
}
