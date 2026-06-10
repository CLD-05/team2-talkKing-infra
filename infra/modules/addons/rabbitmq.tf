# modules/addons/rabbitmq.tf

resource "helm_release" "rabbitmq" {
  # 스위치가 true일 때만 배포되도록 설정
  count = var.enable_rabbitmq ? 1 : 0

  name       = "talkking-rabbitmq"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "rabbitmq"

  # docker-compose 내 rabbitmq:3.12 스펙과 
  # 백엔드 코드가 완벽하게 1:1 호환되는 안정적인 3.12 계열 차트 버전을 지정합니다.
  version = "14.12.0"

  namespace        = "infra"
  create_namespace = true

  # 도커 컴포즈의 RABBITMQ_DEFAULT_USER/PASS 설정을 테라폼 헬름 규격으로 그대로 치환
  set {
    name  = "auth.username"
    value = "talkking" # 🔐 운영계용 커스텀 계정명
  }
  set {
    name  = "auth.password"
    value = var.rabbitmq_password # 🔐 tfvars나 AWS Secrets Manager에서 주입받을 강력한 비번 변수
  }

  set {
    name  = "service.type"
    value = "LoadBalancer"
  }

  set {
    name  = "extraPlugins"
    value = "rabbitmq_management rabbitmq_peer_discovery_k8s"
  }

  timeout = 600
}
