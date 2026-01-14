# =============================================================================
# ALB Module - Resources
# =============================================================================

locals {
  enable_https = var.certificate_arn != ""
}

# -----------------------------------------------------------------------------
# Application Load Balancer
# -----------------------------------------------------------------------------

resource "aws_lb" "main" {
  name               = "${var.project_name}-${var.environment}-alb"
  internal           = var.internal
  load_balancer_type = "application"
  security_groups    = [var.security_group_id]
  subnets            = var.public_subnet_ids

  enable_deletion_protection = var.enable_deletion_protection

  tags = merge(var.tags, {
    Name        = "${var.project_name}-${var.environment}-alb"
    Environment = var.environment
  })
}

# -----------------------------------------------------------------------------
# Target Groups
# -----------------------------------------------------------------------------

resource "aws_lb_target_group" "grafana" {
  name        = "${var.project_name}-${var.environment}-grafana-tg"
  port        = 3000
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    enabled             = true
    healthy_threshold   = var.health_check_config.healthy_threshold
    unhealthy_threshold = var.health_check_config.unhealthy_threshold
    timeout             = var.health_check_config.timeout
    interval            = var.health_check_config.interval
    path                = "/api/health"
    matcher             = "200"
  }

  tags = merge(var.tags, {
    Name        = "${var.project_name}-${var.environment}-grafana-tg"
    Environment = var.environment
  })
}

resource "aws_lb_target_group" "mimir" {
  name        = "${var.project_name}-${var.environment}-mimir-tg"
  port        = 8080
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    enabled             = true
    healthy_threshold   = var.health_check_config.healthy_threshold
    unhealthy_threshold = var.health_check_config.unhealthy_threshold
    timeout             = var.health_check_config.timeout
    interval            = var.health_check_config.interval
    path                = "/ready"
    matcher             = "200"
  }

  tags = merge(var.tags, {
    Name        = "${var.project_name}-${var.environment}-mimir-tg"
    Environment = var.environment
  })
}

resource "aws_lb_target_group" "loki" {
  name        = "${var.project_name}-${var.environment}-loki-tg"
  port        = 3100
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    enabled             = true
    healthy_threshold   = var.health_check_config.healthy_threshold
    unhealthy_threshold = var.health_check_config.unhealthy_threshold
    timeout             = var.health_check_config.timeout
    interval            = var.health_check_config.interval
    path                = "/ready"
    matcher             = "200"
  }

  tags = merge(var.tags, {
    Name        = "${var.project_name}-${var.environment}-loki-tg"
    Environment = var.environment
  })
}

resource "aws_lb_target_group" "tempo" {
  name        = "${var.project_name}-${var.environment}-tempo-tg"
  port        = 3200
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    enabled             = true
    healthy_threshold   = var.health_check_config.healthy_threshold
    unhealthy_threshold = var.health_check_config.unhealthy_threshold
    timeout             = var.health_check_config.timeout
    interval            = var.health_check_config.interval
    path                = "/ready"
    matcher             = "200"
  }

  tags = merge(var.tags, {
    Name        = "${var.project_name}-${var.environment}-tempo-tg"
    Environment = var.environment
  })
}

resource "aws_lb_target_group" "pyroscope" {
  name        = "${var.project_name}-${var.environment}-pyroscope-tg"
  port        = 4040
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    enabled             = true
    healthy_threshold   = var.health_check_config.healthy_threshold
    unhealthy_threshold = var.health_check_config.unhealthy_threshold
    timeout             = var.health_check_config.timeout
    interval            = var.health_check_config.interval
    path                = "/ready"
    matcher             = "200"
  }

  tags = merge(var.tags, {
    Name        = "${var.project_name}-${var.environment}-pyroscope-tg"
    Environment = var.environment
  })
}

# -----------------------------------------------------------------------------
# HTTP Listener
# -----------------------------------------------------------------------------

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = local.enable_https ? "redirect" : "forward"

    dynamic "redirect" {
      for_each = local.enable_https ? [1] : []
      content {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }

    target_group_arn = local.enable_https ? null : aws_lb_target_group.grafana.arn
  }
}

# -----------------------------------------------------------------------------
# HTTPS Listener (only if certificate is provided)
# -----------------------------------------------------------------------------

resource "aws_lb_listener" "https" {
  count = local.enable_https ? 1 : 0

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

# -----------------------------------------------------------------------------
# Listener Rules (HTTP - only when HTTPS is disabled)
# -----------------------------------------------------------------------------

resource "aws_lb_listener_rule" "mimir_http" {
  count = local.enable_https ? 0 : 1

  listener_arn = aws_lb_listener.http.arn
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

resource "aws_lb_listener_rule" "loki_http" {
  count = local.enable_https ? 0 : 1

  listener_arn = aws_lb_listener.http.arn
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

resource "aws_lb_listener_rule" "tempo_http" {
  count = local.enable_https ? 0 : 1

  listener_arn = aws_lb_listener.http.arn
  priority     = 30

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tempo.arn
  }

  condition {
    path_pattern {
      values = ["/api/traces", "/v1/traces", "/tempo/*"]
    }
  }
}

resource "aws_lb_listener_rule" "pyroscope_http" {
  count = local.enable_https ? 0 : 1

  listener_arn = aws_lb_listener.http.arn
  priority     = 40

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.pyroscope.arn
  }

  condition {
    path_pattern {
      values = ["/pyroscope/*", "/ingest", "/querier.v1.*"]
    }
  }
}

# -----------------------------------------------------------------------------
# Listener Rules (HTTPS - only when certificate is provided)
# -----------------------------------------------------------------------------

resource "aws_lb_listener_rule" "mimir_https" {
  count = local.enable_https ? 1 : 0

  listener_arn = aws_lb_listener.https[0].arn
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

resource "aws_lb_listener_rule" "loki_https" {
  count = local.enable_https ? 1 : 0

  listener_arn = aws_lb_listener.https[0].arn
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

resource "aws_lb_listener_rule" "tempo_https" {
  count = local.enable_https ? 1 : 0

  listener_arn = aws_lb_listener.https[0].arn
  priority     = 30

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tempo.arn
  }

  condition {
    path_pattern {
      values = ["/api/traces", "/v1/traces", "/tempo/*"]
    }
  }
}

resource "aws_lb_listener_rule" "pyroscope_https" {
  count = local.enable_https ? 1 : 0

  listener_arn = aws_lb_listener.https[0].arn
  priority     = 40

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.pyroscope.arn
  }

  condition {
    path_pattern {
      values = ["/pyroscope/*", "/ingest", "/querier.v1.*"]
    }
  }
}
