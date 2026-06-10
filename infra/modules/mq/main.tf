resource "aws_mq_broker" "rabbitmq" {
  broker_name        = "talkking-${var.environment}-mq"
  engine_type        = "RabbitMQ"
  engine_version     = "3.13"
  host_instance_type = "mq.t3.micro"
  deployment_mode    = "SINGLE_INSTANCE"

  # 추가: 퍼블릭 접근 차단
  publicly_accessible = false

  user {
    username = "talkking"
    password = var.mq_password
  }

  subnet_ids      = var.subnet_ids
  security_groups = var.security_groups

  # 추가: 수정 사항 즉시 반영 (개발 환경 필수)
  apply_immediately = true

}
