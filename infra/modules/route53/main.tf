data "aws_route53_zone" "this" {
  count = var.create_alias_record ? 1 : 0

  name         = var.zone_name
  private_zone = var.private_zone
}

resource "aws_route53_record" "alias" {
  count = var.create_alias_record ? 1 : 0

  zone_id = data.aws_route53_zone.this[0].zone_id
  name    = var.record_name
  type    = "A"

  alias {
    name                   = var.alias_dns_name
    zone_id                = var.alias_zone_id
    evaluate_target_health = true
  }
}
