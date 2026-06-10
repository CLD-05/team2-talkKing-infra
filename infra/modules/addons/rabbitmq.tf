resource "helm_release" "rabbitmq" {
  # 🎯 스위치가 켜졌을 때만 1개를 만들고, 꺼지면(false) 생성하지 않습니다.
  count = var.enable_rabbitmq ? 1 : 0

  name       = "talkking-rabbitmq"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "rabbitmq"
  version    = "15.0.0"

  namespace        = "infra"
  create_namespace = true

  set {
    name  = "auth.username"
    value = "guest"
  }
  set {
    name  = "auth.password"
    value = "guest"
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
