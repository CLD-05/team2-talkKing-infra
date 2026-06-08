locals {
  common_tags = merge(var.tags, {
    Project     = var.project
    Environment = var.environment
    ManagedBy   = "terraform"
  })
}

resource "aws_ssm_parameter" "this" {
  for_each = var.parameters

  name        = "/${var.project}/${var.environment}/${each.key}"
  description = each.value.description
  type        = each.value.secure ? "SecureString" : "String"
  value       = each.value.value
  tier        = "Standard"
  overwrite   = true

  tags = merge(local.common_tags, {
    Name = "/${var.project}/${var.environment}/${each.key}"
  })
}
