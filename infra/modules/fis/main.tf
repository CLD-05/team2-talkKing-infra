resource "aws_fis_experiment_template" "pod_memory_stress" {
  description = "FIS Pod Memory Stress Experiment to Trigger High Restart Rate Alert"
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
    name      = "memory-stress-action"
    action_id = "aws:eks:pod-memory-stress"

    target {
      key   = "Pods"
      value = "targeted-pods"
    }

    parameter {
      key   = "duration"
      value = "PT1M"
    }

    parameter {
      key   = "percent"
      value = "20"
    }

    parameter {
      key   = "kubernetesServiceAccount"
      value = var.kubernetes_service_account
    }
  }

  tags = merge(var.tags, {
    Name = "${var.project}-${var.environment}-fis-chat-memory-stress"
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
  }

  tags = merge(var.tags, {
    Name = "${var.project}-${var.environment}-fis-chat-cpu-stress"
  })
}

resource "aws_fis_experiment_template" "pod_kill" {
  description = "FIS Pod Kill Chaos Experiment to Test AI Self-Healing Pipeline"
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
    name      = "pod-kill-action"
    action_id = "aws:eks:pod-delete"

    target {
      key   = "Pods"
      value = "targeted-pods"
    }

    parameter {
      key   = "kubernetesServiceAccount"
      value = var.kubernetes_service_account
    }
  }

  tags = merge(var.tags, {
    Name = "${var.project}-${var.environment}-fis-chat-pod-kill"
  })
}
