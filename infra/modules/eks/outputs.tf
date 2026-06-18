output "cluster_name" {
  description = "EKS cluster name."
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "EKS API endpoint."
  value       = module.eks.cluster_endpoint
  sensitive   = true
}

output "cluster_version" {
  description = "EKS cluster Kubernetes version."
  value       = module.eks.cluster_version
}

output "cluster_security_group_id" {
  description = "EKS cluster security group ID."
  value       = module.eks.cluster_security_group_id
}

output "node_security_group_id" {
  description = "EKS node security group ID."
  value       = module.eks.node_security_group_id
}

output "oidc_provider_arn" {
  description = "EKS OIDC provider ARN."
  value       = module.eks.oidc_provider_arn
}

output "oidc_provider_url" {
  description = "EKS OIDC provider URL without https://."
  value       = module.eks.oidc_provider
}

output "alb_controller_role_arn" {
  description = "AWS Load Balancer Controller IRSA role ARN."
  value       = module.alb_controller_irsa.iam_role_arn
}

output "ebs_csi_role_arn" {
  description = "EBS CSI Driver IRSA role ARN."
  value       = module.ebs_csi_irsa.iam_role_arn
}

output "external_secrets_role_arn" {
  description = "External Secrets Operator IRSA role ARN."
  value       = module.external_secrets_irsa.iam_role_arn
}

output "cluster_arn" {
  description = "The Amazon Resource Name (ARN) of the EKS cluster"
  # 해당 모듈 안에서 aws_eks_cluster 리소스가 정의된 이름을 적어줍니다. (예: aws_eks_cluster.this.arn)
  value = module.eks.cluster_arn
}
