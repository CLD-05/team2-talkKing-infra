resource "aws_fis_experiment_template" "pod_delete" {
  description = "FIS Pod Delete Experiment for chat-service"
  role_arn    = aws_iam_role.fis_role.arn

  stop_condition {
    source = "none"
  }

  # 🎯 대상 (Target): talkking-dev 네임스페이스의 chat Pod 중 딱 1개
  target {
    name           = "targeted-pods"
    resource_type  = "aws:eks:pod"
    selection_mode = "COUNT(1)"

    resource_arns = [var.cluster_arn]

    filter {
      path   = "Namespace"
      values = [var.namespace]
    }

    # 💡 실제 라벨에 맞춰 app=chat으로 수정 완료!
    filter {
      path   = "Selector"
      values = ["app=chat"]
    }
  }

  # 💥 액션 (Action)
  action {
    name      = "delete-pods-action"
    action_id = "aws:eks:pod-delete"

    target {
      key   = "Pods"
      value = "targeted-pods"
    }

    parameter {
      key   = "duration"
      value = "PT1M"
    }
  }

  tags = merge(var.tags, {
    Name = "${var.project}-${var.environment}-fis-chat-service-delete"
  })
}

# ==========================================
# 시나리오 5: chat-service 네트워크 지연(Latency) 실험
# ==========================================
resource "aws_fis_experiment_template" "pod_latency" {
  description = "FIS Pod Network Latency Experiment for chat-service"
  role_arn    = aws_iam_role.fis_role.arn

  stop_condition { source = "none" }

  target {
    name           = "targeted-pods"
    resource_type  = "aws:eks:pod"
    selection_mode = "COUNT(1)" # 2개 중 1개만 저격

    resource_arns = [var.cluster_arn]

    filter {
      path   = "Namespace"
      values = [var.namespace]
    }
    filter {
      path   = "Selector"
      values = ["app=chat"] # 실제 라벨 확인 완료한 값
    }
  }

  action {
    name      = "latency-injection-action"
    action_id = "aws:eks:pod-network-latency" # 💡 네트워크 지연 액션

    target {
      key   = "Pods"
      value = "targeted-pods"
    }

    # 200ms 지연을 2분(PT2M) 동안 주입
    parameter {
      key   = "duration"
      value = "PT2M"
    }
    parameter {
      key   = "milliseconds"
      value = "200"
    }
  }

  tags = merge(var.tags, {
    Name = "${var.project}-${var.environment}-fis-chat-latency"
  })
}

# ==========================================
# 시나리오 6: chat-service CPU 부하(Stress) 실험
# ==========================================
resource "aws_fis_experiment_template" "pod_cpu_stress" {
  description = "FIS Pod CPU Stress Experiment for chat-service"
  role_arn    = aws_iam_role.fis_role.arn

  stop_condition { source = "none" }

  target {
    name           = "targeted-pods"
    resource_type  = "aws:eks:pod"
    selection_mode = "COUNT(1)"

    resource_arns = [var.cluster_arn]

    filter {
      path   = "Namespace"
      values = [var.namespace]
    }
    filter {
      path   = "Selector"
      values = ["app=chat"]
    }
  }

  action {
    name      = "cpu-stress-action"
    action_id = "aws:eks:pod-cpu-stress" # 💡 CPU 부하 액션

    target {
      key   = "Pods"
      value = "targeted-pods"
    }

    # 1개 코어 수준의 부하를 2분(PT2M) 동안 주입
    # 현재 chat-service의 limit이 500m(0.5코어)이므로, 100% 한계치까지 채우게 됩니다.
    parameter {
      key   = "duration"
      value = "PT2M"
    }
    parameter {
      key   = "workers"
      value = "1"
    }
  }

  tags = merge(var.tags, {
    Name = "${var.project}-${var.environment}-fis-chat-cpu-stress"
  })
}
