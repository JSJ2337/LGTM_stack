# ALB Module - LGTM Stack

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "public_subnet_ids" {
  description = "Public subnet IDs"
  type        = list(string)
}

variable "security_group_id" {
  description = "ALB security group ID"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "certificate_arn" {
  description = "ACM certificate ARN"
  type        = string
}

variable "domain_name" {
  description = "Domain name for Grafana"
  type        = string
}

# =============================================================================
# Application Load Balancer
# =============================================================================

resource "aws_lb" "main" {
  name               = "lgtm-${var.environment}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.security_group_id]
  subnets            = var.public_subnet_ids

  enable_deletion_protection = true

  tags = {
    Name        = "lgtm-${var.environment}-alb"
    Environment = var.environment
  }
}

# =============================================================================
# Target Groups
# =============================================================================

resource "aws_lb_target_group" "grafana" {
  name        = "lgtm-${var.environment}-grafana-tg"
  port        = 3000
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
    path                = "/api/health"
    matcher             = "200"
  }

  tags = {
    Name        = "lgtm-${var.environment}-grafana-tg"
    Environment = var.environment
  }
}

resource "aws_lb_target_group" "mimir" {
  name        = "lgtm-${var.environment}-mimir-tg"
  port        = 8080
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
    path                = "/-/ready"
    matcher             = "200"
  }

  tags = {
    Name        = "lgtm-${var.environment}-mimir-tg"
    Environment = var.environment
  }
}

resource "aws_lb_target_group" "loki" {
  name        = "lgtm-${var.environment}-loki-tg"
  port        = 3100
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
    path                = "/ready"
    matcher             = "200"
  }

  tags = {
    Name        = "lgtm-${var.environment}-loki-tg"
    Environment = var.environment
  }
}

resource "aws_lb_target_group" "tempo" {
  name        = "lgtm-${var.environment}-tempo-tg"
  port        = 3200
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
    path                = "/ready"
    matcher             = "200"
  }

  tags = {
    Name        = "lgtm-${var.environment}-tempo-tg"
    Environment = var.environment
  }
}

# =============================================================================
# Listeners
# =============================================================================

# HTTP Listener (Redirect to HTTPS)
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

# HTTPS Listener
resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.main.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.grafana.arn
  }
}

# =============================================================================
# Listener Rules
# =============================================================================

# Mimir API
resource "aws_lb_listener_rule" "mimir" {
  listener_arn = aws_lb_listener.https.arn
  priority     = 10

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.mimir.arn
  }

  condition {
    path_pattern {
      values = ["/api/v1/push", "/prometheus/*"]
    }
  }
}

# Loki API
resource "aws_lb_listener_rule" "loki" {
  listener_arn = aws_lb_listener.https.arn
  priority     = 20

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.loki.arn
  }

  condition {
    path_pattern {
      values = ["/loki/*"]
    }
  }
}

# Tempo API
resource "aws_lb_listener_rule" "tempo" {
  listener_arn = aws_lb_listener.https.arn
  priority     = 30

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tempo.arn
  }

  condition {
    path_pattern {
      values = ["/api/traces", "/v1/traces"]
    }
  }
}

# =============================================================================
# Outputs
# =============================================================================

output "dns_name" {
  description = "ALB DNS name"
  value       = aws_lb.main.dns_name
}

output "zone_id" {
  description = "ALB zone ID"
  value       = aws_lb.main.zone_id
}

output "arn" {
  description = "ALB ARN"
  value       = aws_lb.main.arn
}

output "grafana_target_group_arn" {
  description = "Grafana target group ARN"
  value       = aws_lb_target_group.grafana.arn
}

output "mimir_target_group_arn" {
  description = "Mimir target group ARN"
  value       = aws_lb_target_group.mimir.arn
}

output "loki_target_group_arn" {
  description = "Loki target group ARN"
  value       = aws_lb_target_group.loki.arn
}

output "tempo_target_group_arn" {
  description = "Tempo target group ARN"
  value       = aws_lb_target_group.tempo.arn
}
