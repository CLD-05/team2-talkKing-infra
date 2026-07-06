locals {
  common_tags = merge(var.tags, {
    Project     = var.project
    Environment = var.environment
    ManagedBy   = "terraform"
  })
}

# 1. 💡 우리가 미리 만들어둔 AWS Secrets Manager 주머니 데이터를 불러옵니다.
data "aws_secretsmanager_secret" "db_secret" {
  name = "team2-talkking/prod/database"
}

data "aws_secretsmanager_secret_version" "db_secret_version" {
  secret_id = data.aws_secretsmanager_secret.db_secret.id
}

resource "aws_db_subnet_group" "this" {
  name       = "${var.project}-${var.environment}-db-subnet-group"
  subnet_ids = var.database_subnet_ids

  tags = merge(local.common_tags, {
    Name = "${var.project}-${var.environment}-db-subnet-group"
  })
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
  description              = "Allow database traffic from ${each.value}."
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
  identifier = "${var.project}-${var.environment}-db"

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

  # 2. 🚨 AWS 자동 관리 옵션을 끄고, 우리 주머니의 비밀번호를 직접 주입합니다.
  manage_master_user_password = false
  password                    = jsondecode(data.aws_secretsmanager_secret_version.db_secret_version.secret_string)["password"]

  # 3. ⏱️ 변경 사항이 즉시 RDS에 반영되도록 설정합니다.
  apply_immediately = true

  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [aws_security_group.this.id]
  multi_az               = var.multi_az
  publicly_accessible    = false

  backup_retention_period = var.backup_retention_period
  deletion_protection     = var.deletion_protection
  skip_final_snapshot     = var.skip_final_snapshot
  final_snapshot_identifier = var.skip_final_snapshot ? null : (
    "${var.project}-${var.environment}-db-final-snapshot"
  )

  tags = merge(local.common_tags, {
    Name = "${var.project}-${var.environment}-db"
  })
}
