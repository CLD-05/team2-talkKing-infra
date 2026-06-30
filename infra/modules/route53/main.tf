# ==========================================================
# 1. ArgoCD가 생성한 AWS ALB 정보를 태그 기반으로 자동 실시간 조회
# ==========================================================
data "aws_lb" "k8s_alb" {
  tags = {
    # 💡 [필수 수정] 현재 사용 중이신 EKS 클러스터 이름을 적어주세요.
    "elbv2.k8s.aws/cluster" = "team2-talkking-prod-cluster"

    # 쿠버네티스 인그레스 정보 기반 태그 (이 부분은 고정이므로 그대로 두시면 됩니다)
    "ingress.k8s.aws/resource" = "Ingress:talkking-prod/talkking-prod-ingress"
  }
}

# ==========================================================
# 2. talkking.site 호스팅 영역 생성
# ==========================================================
resource "aws_route53_zone" "talkking_zone" {
  name    = "talkking.site"
  comment = "Hosted zone for talkking.site"

  # 실수로 테라폼 destroy를 실행해도 영역이 삭제되어 
  # 네임서버가 바뀌는 대참사를 막아주는 안전장치
  lifecycle {
    prevent_destroy = true
  }
}

# ==========================================================
# 3. Route 53 A 레코드 생성 (자동으로 긁어온 ALB 주소 매핑)
# ==========================================================
resource "aws_route53_record" "alias" {
  zone_id = aws_route53_zone.talkking_zone.zone_id
  name    = "talkking.site" # 도메인 본 주소 (www가 필요하면 "www.talkking.site")
  type    = "A"

  alias {
    # 💡 위 데이터 소스(data.aws_lb)가 자동으로 알아온 DNS 주소와 리전 Zone ID를 연동합니다.
    name                   = data.aws_lb.k8s_alb.dns_name
    zone_id                = data.aws_lb.k8s_alb.zone_id
    evaluate_target_health = true
  }
}

# ==========================================================
# 4. 가비아에 등록할 네임서버 4개 화면 출력 설정
# ==========================================================
output "talkking_nameservers" {
  description = "가비아 네임서버 설정 창에 입력해야 할 AWS 네임서버 리스트입니다."
  value       = aws_route53_zone.talkking_zone.name_servers
}
