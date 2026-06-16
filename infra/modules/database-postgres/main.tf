locals {
  common_tags = merge(var.tags, {
    Project     = var.project
    Environment = var.environment
    ManagedBy   = "terraform"
  })
}

resource "aws_db_subnet_group" "this" {
  name       = "${var.project}-${var.environment}-db-subnet-group"
  subnet_ids = var.database_subnet_ids

  tags = merge(local.common_tags, {
    Name = "${var.project}-${var.environment}-db-subnet-group"
  })
}

# PostgreSQL 커스텀 파라미터 그룹 추가
resource "aws_db_parameter_group" "this" {
  name   = "${var.project}-${var.environment}-pg-parameter-group"
  family = "postgres16" # var.engine_version 버전에 맞게 매칭 (예: postgres15, postgres16)

  parameter {
    name  = "timezone"
    value = "Asia/Seoul"
  }

  tags = local.common_tags
}

resource "aws_security_group" "this" {
  name        = "${var.project}-${var.environment}-db-sg"
  description = "RDS security group."
  vpc_id      = var.vpc_id

  tags = merge(local.common_tags, {
    Name = "${var.project}-${var.environment}-db-sg"
  })
}

resource "aws_security_group_rule" "from_eks_nodes" {
  type                     = "ingress"
  from_port                = var.db_port
  to_port                  = var.db_port
  protocol                 = "tcp"
  source_security_group_id = var.eks_node_security_group_id
  security_group_id        = aws_security_group.this.id
  description              = "Allow database traffic from EKS nodes."
}

resource "aws_security_group_rule" "from_additional_security_groups" {
  for_each = toset(var.additional_allowed_security_group_ids)

  type                     = "ingress"
  from_port                = var.db_port
  to_port                  = var.db_port
  protocol                 = "tcp"
  source_security_group_id = each.value
  security_group_id        = aws_security_group.this.id
  description              = "Allow database traffic from allowed security group: ${each.value}."
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

  manage_master_user_password = true

  db_subnet_group_name   = aws_db_subnet_group.this.name
  parameter_group_name   = aws_db_parameter_group.this.name # 파라미터 그룹 연결
  vpc_security_group_ids = [aws_security_group.this.id]
  multi_az               = var.multi_az
  publicly_accessible    = false

  backup_retention_period = var.backup_retention_period
  deletion_protection     = var.deletion_protection
  skip_final_snapshot     = var.skip_final_snapshot

  # 명시적으로 식별자를 주되 skip_final_snapshot 유무로 동작을 제어하는 것이 밸리데이션 에러를 줄입니다.
  final_snapshot_identifier = "${var.project}-${var.environment}-alert-history-final-snapshot"

  tags = merge(local.common_tags, {
    Name = "${var.project}-${var.environment}-alert-history-db"
  })
}
