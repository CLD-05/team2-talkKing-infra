resource "aws_fis_experiment_template" "pod_delete" {
  description = "FIS Pod Delete Experiment for chat-service"
  role_arn    = aws_iam_role.fis_role.arn

  stop_condition {
    source = "none"
  }

  target {
    name           = "targeted-pods"
    resource_type  = "aws:eks:pod"
    selection_mode = "COUNT(1)"

    parameters = {
      clusterIdentifier = var.cluster_arn
      namespace         = var.namespace
      selectorType      = "labelSelector"
      selectorValue     = var.pod_selector
    }
  }

  action {
    name      = "delete-pods-action"
    action_id = "aws:eks:pod-delete"

    target {
      key   = "Pods"
      value = "targeted-pods"
    }

    parameter {
      key   = "kubernetesServiceAccount"
      value = var.kubernetes_service_account
    }

    parameter {
      key   = "kubernetesServiceAccount"
      value = "fis-experiment"
    }
  }

  tags = merge(var.tags, {
    Name = "${var.project}-${var.environment}-fis-chat-service-delete"
  })
}

resource "aws_fis_experiment_template" "pod_latency" {
  description = "FIS Pod Network Latency Experiment for chat-service"
  role_arn    = aws_iam_role.fis_role.arn

  stop_condition {
    source = "none"
  }

  target {
    name           = "targeted-pods"
    resource_type  = "aws:eks:pod"
    selection_mode = "COUNT(1)"

    parameters = {
      clusterIdentifier = var.cluster_arn
      namespace         = var.namespace
      selectorType      = "labelSelector"
      selectorValue     = var.pod_selector
    }
  }

  action {
    name      = "latency-injection-action"
    action_id = "aws:eks:pod-network-latency"

    target {
      key   = "Pods"
      value = "targeted-pods"
    }

    parameter {
      key   = "duration"
      value = "PT2M"
    }

    parameter {
      key   = "delayMilliseconds"
      value = "200"
    }

    parameter {
      key   = "kubernetesServiceAccount"
      value = var.kubernetes_service_account
    }

    parameter {
      key   = "kubernetesServiceAccount"
      value = "fis-experiment"
    }
  }

  tags = merge(var.tags, {
    Name = "${var.project}-${var.environment}-fis-chat-latency"
  })
}

resource "aws_fis_experiment_template" "pod_cpu_stress" {
  description = "FIS Pod CPU Stress Experiment for chat-service"
  role_arn    = aws_iam_role.fis_role.arn

  stop_condition {
    source = "none"
  }

  target {
    name           = "targeted-pods"
    resource_type  = "aws:eks:pod"
    selection_mode = "COUNT(1)"

    parameters = {
      clusterIdentifier = var.cluster_arn
      namespace         = var.namespace
      selectorType      = "labelSelector"
      selectorValue     = var.pod_selector
    }
  }

  action {
    name      = "cpu-stress-action"
    action_id = "aws:eks:pod-cpu-stress"

    target {
      key   = "Pods"
      value = "targeted-pods"
    }

    parameter {
      key   = "duration"
      value = "PT2M"
    }

    parameter {
      key   = "workers"
      value = "1"
    }

    parameter {
      key   = "kubernetesServiceAccount"
      value = var.kubernetes_service_account
    }

    parameter {
      key   = "kubernetesServiceAccount"
      value = "fis-experiment"
    }
  }

  tags = merge(var.tags, {
    Name = "${var.project}-${var.environment}-fis-chat-cpu-stress"
  })
}
