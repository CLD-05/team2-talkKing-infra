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

# 4. ACM 무료 SSL 인증서 신청
resource "aws_acm_certificate" "this" {
  domain_name       = var.zone_name
  validation_method = "DNS"

  # www.talkking.site 같은 서브도메인도 함께 쓸 수 있도록 와일드카드 자동 추가
  subject_alternative_names = ["*.${var.zone_name}"]
  tags                      = local.common_tags

  lifecycle {
    create_before_destroy = true
  }
}

# 5. Route 53에 ACM 소유권 검증을 위한 DNS 레코드 자동 생성
resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.this.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = aws_route53_zone.this.zone_id
}

# 6. AWS 내부에서 인증서 검증이 완료될 때까지 대기 처리
resource "aws_acm_validation" "this" {
  certificate_arn         = aws_acm_certificate.this.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}
