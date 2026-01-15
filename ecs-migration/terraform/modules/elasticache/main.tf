# =============================================================================
# ElastiCache Module - Resources
# =============================================================================
# LGTM 스택용 Memcached 클러스터
# Mimir, Loki의 쿼리 캐시 및 인덱스 캐시에 사용
# =============================================================================

# -----------------------------------------------------------------------------
# ElastiCache Subnet Group
# -----------------------------------------------------------------------------

resource "aws_elasticache_subnet_group" "main" {
  name        = "${var.project_name}-${var.environment}-cache-subnet"
  description = "Subnet group for LGTM Memcached cluster"
  subnet_ids  = var.private_subnet_ids

  tags = merge(var.tags, {
    Name        = "${var.project_name}-${var.environment}-cache-subnet"
    Environment = var.environment
  })
}

# -----------------------------------------------------------------------------
# ElastiCache Security Group
# -----------------------------------------------------------------------------

resource "aws_security_group" "memcached" {
  name        = "${var.project_name}-${var.environment}-memcached-sg"
  description = "Security group for LGTM Memcached cluster"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Memcached from ECS"
    from_port       = 11211
    to_port         = 11211
    protocol        = "tcp"
    security_groups = [var.ecs_security_group_id]
  }

  egress {
    description = "All outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name        = "${var.project_name}-${var.environment}-memcached-sg"
    Environment = var.environment
  })
}

# -----------------------------------------------------------------------------
# ElastiCache Memcached Cluster
# -----------------------------------------------------------------------------

resource "aws_elasticache_cluster" "memcached" {
  cluster_id           = "${var.project_name}-${var.environment}-memcached"
  engine               = "memcached"
  engine_version       = var.memcached_version
  node_type            = var.node_type
  num_cache_nodes      = var.num_cache_nodes
  port                 = 11211
  parameter_group_name = aws_elasticache_parameter_group.memcached.name
  subnet_group_name    = aws_elasticache_subnet_group.main.name
  security_group_ids   = [aws_security_group.memcached.id]

  az_mode = var.num_cache_nodes > 1 ? "cross-az" : "single-az"

  # 유지보수 창
  maintenance_window = var.maintenance_window

  # 알림
  notification_topic_arn = var.sns_topic_arn

  tags = merge(var.tags, {
    Name        = "${var.project_name}-${var.environment}-memcached"
    Environment = var.environment
    Component   = "cache"
  })
}

# -----------------------------------------------------------------------------
# ElastiCache Parameter Group
# -----------------------------------------------------------------------------

resource "aws_elasticache_parameter_group" "memcached" {
  name        = "${var.project_name}-${var.environment}-memcached-params"
  family      = "memcached1.6"
  description = "Custom parameter group for LGTM Memcached"

  # 최대 메모리 정책
  parameter {
    name  = "max_item_size"
    value = var.max_item_size
  }

  tags = merge(var.tags, {
    Name        = "${var.project_name}-${var.environment}-memcached-params"
    Environment = var.environment
  })
}