locals {
  common_tags = merge(var.tags, {
    ManagedBy = "terraform"
  })
}

data "aws_lb" "k8s_alb" {
  count = var.create_alias_record ? 1 : 0

  tags = {
    "elbv2.k8s.aws/cluster" = var.cluster_name
    "ingress.k8s.aws/stack" = "${var.ingress_namespace}/${var.ingress_name}"
  }
}

resource "aws_route53_zone" "this" {
  name    = var.zone_name
  comment = "Hosted zone for ${var.zone_name}"
  tags    = local.common_tags

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_route53_record" "alias" {
  count = var.create_alias_record ? 1 : 0

  zone_id = aws_route53_zone.this.zone_id
  name    = var.record_name
  type    = "A"

  alias {
    name                   = data.aws_lb.k8s_alb[0].dns_name
    zone_id                = data.aws_lb.k8s_alb[0].zone_id
    evaluate_target_health = true
  }
}
