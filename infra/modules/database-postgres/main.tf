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

resource "aws_secretsmanager_secret" "app" {
  name                    = "${var.project}/${var.environment}/alert-history-db"
  recovery_window_in_days = 0

  tags = merge(local.common_tags, {
    Name = "${var.project}-${var.environment}-alert-history-db-secret"
  })
}

data "aws_secretsmanager_secret_version" "managed_master" {
  secret_id = aws_db_instance.this.master_user_secret[0].secret_arn

  depends_on = [aws_db_instance.this]
}

resource "aws_secretsmanager_secret_version" "app" {
  secret_id = aws_secretsmanager_secret.app.id
  secret_string = jsonencode({
    username             = var.master_username
    password             = jsondecode(data.aws_secretsmanager_secret_version.managed_master.secret_string).password
    engine               = var.engine
    host                 = aws_db_instance.this.address
    port                 = aws_db_instance.this.port
    dbname               = aws_db_instance.this.db_name
    dbInstanceIdentifier = aws_db_instance.this.identifier
  })
}
