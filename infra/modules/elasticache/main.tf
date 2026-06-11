locals {
  common_tags = merge(var.tags, {
    Project     = var.project
    Environment = var.environment
    ManagedBy   = "terraform"
  })
}

resource "aws_elasticache_subnet_group" "this" {
  name       = "${var.project}-${var.environment}-redis-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = merge(local.common_tags, {
    Name = "${var.project}-${var.environment}-redis-subnet-group"
  })
}

resource "aws_security_group" "this" {
  name        = "${var.project}-${var.environment}-redis-sg"
  description = "ElastiCache Redis security group."
  vpc_id      = var.vpc_id

  tags = merge(local.common_tags, {
    Name = "${var.project}-${var.environment}-redis-sg"
  })
}

resource "aws_security_group_rule" "from_eks_nodes" {
  type                     = "ingress"
  from_port                = var.port
  to_port                  = var.port
  protocol                 = "tcp"
  source_security_group_id = var.eks_node_security_group_id
  security_group_id        = aws_security_group.this.id
  description              = "Allow Redis traffic from EKS nodes."
}

resource "aws_security_group_rule" "from_additional_security_groups" {
  for_each = toset(var.additional_allowed_security_group_ids)

  type                     = "ingress"
  from_port                = var.port
  to_port                  = var.port
  protocol                 = "tcp"
  source_security_group_id = each.value
  security_group_id        = aws_security_group.this.id
  description              = "Allow Redis traffic from ${each.value}."
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

resource "aws_elasticache_replication_group" "this" {
  replication_group_id = "${var.project}-${var.environment}-redis"
  description          = "Redis for ${var.project} ${var.environment}"

  engine               = "redis"
  engine_version       = var.engine_version
  node_type            = var.node_type
  port                 = var.port
  parameter_group_name = var.parameter_group_name

  subnet_group_name  = aws_elasticache_subnet_group.this.name
  security_group_ids = [aws_security_group.this.id]

  automatic_failover_enabled = var.automatic_failover_enabled
  multi_az_enabled           = var.multi_az_enabled
  num_cache_clusters         = var.num_cache_clusters

  at_rest_encryption_enabled = true
  transit_encryption_enabled = var.transit_encryption_enabled

  snapshot_retention_limit = var.snapshot_retention_limit

  tags = merge(local.common_tags, {
    Name = "${var.project}-${var.environment}-redis"
  })
}
