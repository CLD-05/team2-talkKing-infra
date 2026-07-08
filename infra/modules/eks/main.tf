locals {
  common_tags = merge(var.tags, {
    Project     = var.project
    Environment = var.environment
    ManagedBy   = "terraform"
  })

  bastion_access_entry = var.enable_bastion_access_entry ? {
    bastion = {
      principal_arn = var.bastion_role_arn
      policy_associations = {
        admin = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            type = "cluster"
          }
        }
      }
    }
  } : {}
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.31"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  vpc_id     = var.vpc_id
  subnet_ids = var.private_subnet_ids

  cluster_endpoint_public_access       = var.cluster_endpoint_public_access
  cluster_endpoint_public_access_cidrs = var.cluster_endpoint_public_access_cidrs
  cluster_endpoint_private_access      = true

  enable_cluster_creator_admin_permissions = true
  access_entries                           = merge(local.bastion_access_entry, var.additional_access_entries)
  iam_role_permissions_boundary            = var.permissions_boundary_arn
  node_iam_role_permissions_boundary       = var.permissions_boundary_arn

  cluster_addons = {
    vpc-cni = {
      most_recent = true
    }
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
  }

  eks_managed_node_groups = {
    general = {
      name           = "${var.cluster_name}-general"
      ami_type       = "AL2023_x86_64_STANDARD"
      instance_types = var.node_instance_types

      min_size                      = var.node_min_size
      max_size                      = var.node_max_size
      desired_size                  = var.node_desired_size
      disk_size                     = var.node_disk_size
      iam_role_permissions_boundary = var.permissions_boundary_arn
      create_launch_template        = false
      use_custom_launch_template    = false

      labels = {
        role = "general"
      }

      tags = merge(local.common_tags, {
        "k8s.io/cluster-autoscaler/enabled"             = "true"
        "k8s.io/cluster-autoscaler/${var.cluster_name}" = "owned"
      })

      iam_role_name            = "${var.project}-${var.environment}-node"
      iam_role_use_name_prefix = false
    }
  }

  tags = local.common_tags
}

module "ebs_csi_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.48"

  role_name                     = "${var.cluster_name}-ebs-csi-driver"
  role_permissions_boundary_arn = var.permissions_boundary_arn
  role_policy_arns = {
    ebs_csi = var.ebs_csi_policy_arn
  }

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:ebs-csi-controller-sa"]
    }
  }

  tags = local.common_tags
}

resource "aws_eks_addon" "ebs_csi_driver" {
  count = var.enable_ebs_csi_driver ? 1 : 0

  cluster_name             = module.eks.cluster_name
  addon_name               = "aws-ebs-csi-driver"
  addon_version            = var.ebs_csi_driver_addon_version
  service_account_role_arn = module.ebs_csi_irsa.iam_role_arn

  depends_on = [module.eks.eks_managed_node_groups]

  tags = local.common_tags
}

module "alb_controller_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.48"

  role_name                              = "${var.cluster_name}-alb-controller"
  attach_load_balancer_controller_policy = var.attach_load_balancer_controller_policy
  role_permissions_boundary_arn          = var.permissions_boundary_arn
  role_policy_arns = var.load_balancer_controller_policy_arn == null ? {} : {
    load_balancer_controller = var.load_balancer_controller_policy_arn
  }

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-load-balancer-controller"]
    }
  }

  tags = local.common_tags
}

resource "aws_iam_policy" "external_secrets" {
  name        = "${var.cluster_name}-external-secrets"
  description = "External Secrets Operator read access to SSM Parameter Store and Secrets Manager."

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ssm:GetParameter",
          "ssm:GetParameters",
          "ssm:GetParametersByPath",
          "ssm:DescribeParameters"
        ]
        Resource = "arn:aws:ssm:${var.aws_region}:*:parameter/${var.project}/${var.environment}/*"
      },
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource = [
          "arn:aws:secretsmanager:${var.aws_region}:*:secret:${var.project}/${var.environment}/*",
          "arn:aws:secretsmanager:${var.aws_region}:*:secret:${var.environment}/talkking/*"
        ]
      },
      {
        Effect   = "Allow"
        Action   = ["kms:Decrypt"]
        Resource = "*"
      }
    ]
  })

  tags = local.common_tags
}

module "external_secrets_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.48"

  role_name                     = "${var.cluster_name}-external-secrets"
  role_permissions_boundary_arn = var.permissions_boundary_arn
  role_policy_arns = {
    external_secrets = aws_iam_policy.external_secrets.arn
  }

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["external-secrets:external-secrets"]
    }
  }

  tags = local.common_tags
}
