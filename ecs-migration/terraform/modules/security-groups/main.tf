# =============================================================================
# Security Groups Module - Resources
# =============================================================================

# -----------------------------------------------------------------------------
# ALB Security Group
# -----------------------------------------------------------------------------

resource "aws_security_group" "alb" {
  name        = "${var.project_name}-${var.environment}-alb-sg"
  description = "Security group for LGTM ALB"
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = var.alb_ingress_rules
    content {
      description = ingress.value.description
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }

  egress {
    description = "All outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name        = "${var.project_name}-${var.environment}-alb-sg"
    Environment = var.environment
  })
}

# -----------------------------------------------------------------------------
# ECS Tasks Security Group
# -----------------------------------------------------------------------------

resource "aws_security_group" "ecs" {
  name        = "${var.project_name}-${var.environment}-ecs-sg"
  description = "Security group for LGTM ECS tasks"
  vpc_id      = var.vpc_id

  # ALB에서 들어오는 트래픽 (Grafana, Mimir, Loki, Tempo)
  ingress {
    description     = "Grafana HTTP from ALB"
    from_port       = var.ecs_service_ports.grafana.port
    to_port         = var.ecs_service_ports.grafana.port
    protocol        = var.ecs_service_ports.grafana.protocol
    security_groups = [aws_security_group.alb.id]
  }

  ingress {
    description     = "Mimir HTTP from ALB"
    from_port       = var.ecs_service_ports.mimir.port
    to_port         = var.ecs_service_ports.mimir.port
    protocol        = var.ecs_service_ports.mimir.protocol
    security_groups = [aws_security_group.alb.id]
  }

  ingress {
    description     = "Loki HTTP from ALB"
    from_port       = var.ecs_service_ports.loki.port
    to_port         = var.ecs_service_ports.loki.port
    protocol        = var.ecs_service_ports.loki.protocol
    security_groups = [aws_security_group.alb.id]
  }

  ingress {
    description     = "Tempo HTTP from ALB"
    from_port       = var.ecs_service_ports.tempo.port
    to_port         = var.ecs_service_ports.tempo.port
    protocol        = var.ecs_service_ports.tempo.protocol
    security_groups = [aws_security_group.alb.id]
  }

  ingress {
    description     = "Tempo OTLP gRPC from ALB"
    from_port       = var.ecs_service_ports.tempo_otlp_grpc.port
    to_port         = var.ecs_service_ports.tempo_otlp_grpc.port
    protocol        = var.ecs_service_ports.tempo_otlp_grpc.protocol
    security_groups = [aws_security_group.alb.id]
  }

  ingress {
    description     = "Tempo OTLP HTTP from ALB"
    from_port       = var.ecs_service_ports.tempo_otlp_http.port
    to_port         = var.ecs_service_ports.tempo_otlp_http.port
    protocol        = var.ecs_service_ports.tempo_otlp_http.protocol
    security_groups = [aws_security_group.alb.id]
  }

  ingress {
    description     = "Pyroscope HTTP from ALB"
    from_port       = var.ecs_service_ports.pyroscope.port
    to_port         = var.ecs_service_ports.pyroscope.port
    protocol        = var.ecs_service_ports.pyroscope.protocol
    security_groups = [aws_security_group.alb.id]
  }

  # 내부 통신 (self)
  ingress {
    description = "Mimir HTTP internal"
    from_port   = var.ecs_service_ports.mimir.port
    to_port     = var.ecs_service_ports.mimir.port
    protocol    = var.ecs_service_ports.mimir.protocol
    self        = true
  }

  ingress {
    description = "Mimir gRPC internal"
    from_port   = var.ecs_service_ports.mimir_grpc.port
    to_port     = var.ecs_service_ports.mimir_grpc.port
    protocol    = var.ecs_service_ports.mimir_grpc.protocol
    self        = true
  }

  ingress {
    description = "Loki HTTP internal"
    from_port   = var.ecs_service_ports.loki.port
    to_port     = var.ecs_service_ports.loki.port
    protocol    = var.ecs_service_ports.loki.protocol
    self        = true
  }

  ingress {
    description = "Tempo HTTP internal"
    from_port   = var.ecs_service_ports.tempo.port
    to_port     = var.ecs_service_ports.tempo.port
    protocol    = var.ecs_service_ports.tempo.protocol
    self        = true
  }

  ingress {
    description = "Pyroscope HTTP internal"
    from_port   = var.ecs_service_ports.pyroscope.port
    to_port     = var.ecs_service_ports.pyroscope.port
    protocol    = var.ecs_service_ports.pyroscope.protocol
    self        = true
  }

  ingress {
    description = "Pyroscope gRPC internal"
    from_port   = var.ecs_service_ports.pyroscope_grpc.port
    to_port     = var.ecs_service_ports.pyroscope_grpc.port
    protocol    = var.ecs_service_ports.pyroscope_grpc.protocol
    self        = true
  }

  ingress {
    description = "Alloy HTTP internal"
    from_port   = var.ecs_service_ports.alloy.port
    to_port     = var.ecs_service_ports.alloy.port
    protocol    = var.ecs_service_ports.alloy.protocol
    self        = true
  }

  # Memberlist (클러스터링)
  ingress {
    description = "Memberlist TCP"
    from_port   = var.ecs_service_ports.memberlist_tcp.port
    to_port     = var.ecs_service_ports.memberlist_tcp.port
    protocol    = var.ecs_service_ports.memberlist_tcp.protocol
    self        = true
  }

  ingress {
    description = "Memberlist UDP"
    from_port   = var.ecs_service_ports.memberlist_udp.port
    to_port     = var.ecs_service_ports.memberlist_udp.port
    protocol    = var.ecs_service_ports.memberlist_udp.protocol
    self        = true
  }

  egress {
    description = "All outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name        = "${var.project_name}-${var.environment}-ecs-sg"
    Environment = var.environment
  })
}
