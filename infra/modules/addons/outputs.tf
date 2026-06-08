output "enabled_addons" {
  description = "Enabled platform addon names."
  value = compact([
    var.enable_metrics_server ? "metrics-server" : "",
    var.enable_aws_load_balancer_controller ? "aws-load-balancer-controller" : "",
    var.enable_external_secrets ? "external-secrets" : "",
    var.enable_argocd ? "argocd" : "",
    var.enable_prometheus_stack ? "kube-prometheus-stack" : ""
  ])
}
