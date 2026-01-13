# =============================================================================
# Security Groups Module - Resources
# =============================================================================
# 새로운 규칙 추가 방법:
# 1. common.tfvars의 ecs_service_ports에 항목 추가
# 2. from_alb = true: ALB에서 들어오는 트래픽 허용
# 3. internal = true: 내부 통신 (self) 허용
# =============================================================================

locals {
  # ALB에서 들어오는 트래픽을 허용할 포트들 필터링
  alb_ingress_ports = {
    for k, v in var.ecs_service_ports : k => v
    if lookup(v, "from_alb", false) == true
  }

  # 내부 통신 (self) 허용할 포트들 필터링
  internal_ports = {
    for k, v in var.ecs_service_ports : k => v
    if lookup(v, "internal", false) == true
  }
}

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

  # ALB에서 들어오는 트래픽 (동적 생성)
  dynamic "ingress" {
    for_each = local.alb_ingress_ports
    content {
      description     = "${ingress.value.description} from ALB"
      from_port       = ingress.value.port
      to_port         = ingress.value.port
      protocol        = ingress.value.protocol
      security_groups = [aws_security_group.alb.id]
    }
  }

  # 내부 통신 (동적 생성)
  dynamic "ingress" {
    for_each = local.internal_ports
    content {
      description = "${ingress.value.description} internal"
      from_port   = ingress.value.port
      to_port     = ingress.value.port
      protocol    = ingress.value.protocol
      self        = true
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
    Name        = "${var.project_name}-${var.environment}-ecs-sg"
    Environment = var.environment
  })
}
