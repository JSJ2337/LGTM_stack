# Security Groups Module - LGTM Stack

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

# =============================================================================
# ALB Security Group
# =============================================================================

resource "aws_security_group" "alb" {
  name        = "lgtm-${var.environment}-alb-sg"
  description = "Security group for LGTM ALB"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP (redirect to HTTPS)"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "All outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "lgtm-${var.environment}-alb-sg"
    Environment = var.environment
  }
}

# =============================================================================
# ECS Tasks Security Group
# =============================================================================

resource "aws_security_group" "ecs" {
  name        = "lgtm-${var.environment}-ecs-sg"
  description = "Security group for LGTM ECS tasks"
  vpc_id      = var.vpc_id

  # Grafana (from ALB)
  ingress {
    description     = "Grafana HTTP"
    from_port       = 3000
    to_port         = 3000
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  # Mimir (from ALB + internal)
  ingress {
    description     = "Mimir HTTP from ALB"
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  ingress {
    description = "Mimir HTTP internal"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    self        = true
  }

  ingress {
    description = "Mimir gRPC"
    from_port   = 9095
    to_port     = 9095
    protocol    = "tcp"
    self        = true
  }

  # Loki (from ALB + internal)
  ingress {
    description     = "Loki HTTP from ALB"
    from_port       = 3100
    to_port         = 3100
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  ingress {
    description = "Loki HTTP internal"
    from_port   = 3100
    to_port     = 3100
    protocol    = "tcp"
    self        = true
  }

  # Tempo (from ALB + internal)
  ingress {
    description     = "Tempo HTTP from ALB"
    from_port       = 3200
    to_port         = 3200
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  ingress {
    description = "Tempo HTTP internal"
    from_port   = 3200
    to_port     = 3200
    protocol    = "tcp"
    self        = true
  }

  ingress {
    description     = "Tempo OTLP gRPC"
    from_port       = 4317
    to_port         = 4317
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  ingress {
    description     = "Tempo OTLP HTTP"
    from_port       = 4318
    to_port         = 4318
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  # Pyroscope (from ALB + internal)
  ingress {
    description     = "Pyroscope HTTP from ALB"
    from_port       = 4040
    to_port         = 4040
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  ingress {
    description = "Pyroscope HTTP internal"
    from_port   = 4040
    to_port     = 4040
    protocol    = "tcp"
    self        = true
  }

  ingress {
    description = "Pyroscope gRPC"
    from_port   = 4041
    to_port     = 4041
    protocol    = "tcp"
    self        = true
  }

  # Alloy
  ingress {
    description = "Alloy HTTP"
    from_port   = 12345
    to_port     = 12345
    protocol    = "tcp"
    self        = true
  }

  # Memberlist (클러스터링)
  ingress {
    description = "Memberlist TCP"
    from_port   = 7946
    to_port     = 7946
    protocol    = "tcp"
    self        = true
  }

  ingress {
    description = "Memberlist UDP"
    from_port   = 7946
    to_port     = 7946
    protocol    = "udp"
    self        = true
  }

  egress {
    description = "All outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "lgtm-${var.environment}-ecs-sg"
    Environment = var.environment
  }
}

# =============================================================================
# Outputs
# =============================================================================

output "alb_security_group_id" {
  description = "ALB security group ID"
  value       = aws_security_group.alb.id
}

output "ecs_security_group_id" {
  description = "ECS security group ID"
  value       = aws_security_group.ecs.id
}
