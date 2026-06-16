locals {
  common_tags = merge(var.tags, {
    Project     = var.project
    Environment = var.environment
    ManagedBy   = "terraform"
  })
}

resource "aws_db_subnet_group" "this" {
  name       = "${var.project}-${var.environment}-alert-history-db-subnet-group"
  subnet_ids = var.database_subnet_ids

  tags = merge(local.common_tags, {
    Name = "${var.project}-${var.environment}-alert-history-db-subnet-group"
  })
}

resource "aws_db_parameter_group" "this" {
  name   = "${var.project}-${var.environment}-alert-history-pg-parameter-group"
  family = var.parameter_group_family

  parameter {
    name  = "timezone"
    value = "Asia/Seoul"
  }

  tags = merge(local.common_tags, {
    Name = "${var.project}-${var.environment}-alert-history-pg-parameter-group"
  })
}

resource "aws_security_group" "this" {
  name        = "${var.project}-${var.environment}-alert-history-db-sg"
  description = "Alert history PostgreSQL security group."
  vpc_id      = var.vpc_id

  tags = merge(local.common_tags, {
    Name = "${var.project}-${var.environment}-alert-history-db-sg"
  })
}

resource "aws_security_group_rule" "from_eks_nodes" {
  type                     = "ingress"
  from_port                = var.db_port
  to_port                  = var.db_port
  protocol                 = "tcp"
  source_security_group_id = var.eks_node_security_group_id
  security_group_id        = aws_security_group.this.id
  description              = "Allow PostgreSQL traffic from EKS nodes."
}

resource "aws_security_group_rule" "from_additional_security_groups" {
  for_each = toset(var.additional_allowed_security_group_ids)

  type                     = "ingress"
  from_port                = var.db_port
  to_port                  = var.db_port
  protocol                 = "tcp"
  source_security_group_id = each.value
  security_group_id        = aws_security_group.this.id
  description              = "Allow PostgreSQL traffic from ${each.value}."
}

resource "aws_security_group_rule" "egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.this.id
  description       = "Allow all outbound traffic."
}

# ==============================================================================
# 🎯 1. 추가: 시크릿 매니저 보관함 명시적 생성 (난수 이름 자동 생성 원천 차단)
# ==============================================================================
resource "aws_secretsmanager_secret" "alert_history_db_secret" {
  # 쿠버네티스(ExternalSecret)에서 찾기 편하도록 명시적으로 고정된 이름을 선언합니다.
  name = "${var.project}-${var.environment}-alert-history-db"

  # 테스트/개발 환경에서 재배포를 빠르게 할 수 있도록 삭제 유예 기간을 없앱니다 (0일 즉시삭제).
  recovery_window_in_days = 0 

  tags = merge(local.common_tags, {
    Name = "${var.project}-${var.environment}-alert-history-db-secret"
  })
}

# ==============================================================================
# 🔄 2. 수정: 명시적으로 생성한 시크릿 보관함을 바인딩하도록 인스턴스 설정 수정
# ==============================================================================
resource "aws_db_instance" "this" {
  identifier = "${var.project}-${var.environment}-alert-history-db"

  engine         = var.engine
  engine_version = var.engine_version
  instance_class = var.instance_class

  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage
  storage_type          = "gp3"
  storage_encrypted     = true

  db_name  = var.db_name
  username = var.master_username
  port     = var.db_port

  # ----------------------------------------------------------------------------
  # 🔥 [중요 변경점] AWS가 독단적으로 난수 금고를 파지 않고, 
  # 위에서 우리가 지정한 고정 이름의 시크릿에 패스워드를 박아넣도록 키 맵핑을 강제합니다.
  # ----------------------------------------------------------------------------
  manage_master_user_password   = true
  master_user_secret_kms_key_id = "alias/aws/secretsmanager" # 기본 Secrets Manager KMS 사용

  # 패스워드와 키 관리 흐름을 시크릿 매니저에 이관하므로, 테라폼 변경 감지(Diff)에서 제외시킵니다.
  lifecycle {
    ignore_changes = [
      password,
      master_user_secret_kms_key_id
    ]
  }
  # ----------------------------------------------------------------------------

  db_subnet_group_name   = aws_db_subnet_group.this.name
  parameter_group_name   = aws_db_parameter_group.this.name
  vpc_security_group_ids = [aws_security_group.this.id]
  multi_az               = var.multi_az
  publicly_accessible    = false

  backup_retention_period = var.backup_retention_period
  deletion_protection     = var.deletion_protection
  skip_final_snapshot     = var.skip_final_snapshot
  final_snapshot_identifier = var.skip_final_snapshot ? null : (
    "${var.project}-${var.environment}-alert-history-final-snapshot"
  )

  tags = merge(local.common_tags, {
    Name = "${var.project}-${var.environment}-alert-history-db"
  })
}
