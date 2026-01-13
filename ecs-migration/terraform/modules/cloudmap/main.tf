# CloudMap Module - LGTM Stack Service Discovery

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "namespace" {
  description = "CloudMap namespace name"
  type        = string
  default     = "lgtm.local"
}

# =============================================================================
# Private DNS Namespace
# =============================================================================

resource "aws_service_discovery_private_dns_namespace" "main" {
  name        = var.namespace
  description = "LGTM Stack Service Discovery Namespace"
  vpc         = var.vpc_id

  tags = {
    Name        = var.namespace
    Environment = var.environment
  }
}

# =============================================================================
# Service Discovery Services
# =============================================================================

resource "aws_service_discovery_service" "mimir" {
  name = "mimir"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.main.id

    dns_records {
      ttl  = 10
      type = "A"
    }

    routing_policy = "MULTIVALUE"
  }

  health_check_custom_config {
    failure_threshold = 1
  }

  tags = {
    Name        = "mimir"
    Environment = var.environment
  }
}

resource "aws_service_discovery_service" "loki" {
  name = "loki"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.main.id

    dns_records {
      ttl  = 10
      type = "A"
    }

    routing_policy = "MULTIVALUE"
  }

  health_check_custom_config {
    failure_threshold = 1
  }

  tags = {
    Name        = "loki"
    Environment = var.environment
  }
}

resource "aws_service_discovery_service" "tempo" {
  name = "tempo"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.main.id

    dns_records {
      ttl  = 10
      type = "A"
    }

    routing_policy = "MULTIVALUE"
  }

  health_check_custom_config {
    failure_threshold = 1
  }

  tags = {
    Name        = "tempo"
    Environment = var.environment
  }
}

resource "aws_service_discovery_service" "pyroscope" {
  name = "pyroscope"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.main.id

    dns_records {
      ttl  = 10
      type = "A"
    }

    routing_policy = "MULTIVALUE"
  }

  health_check_custom_config {
    failure_threshold = 1
  }

  tags = {
    Name        = "pyroscope"
    Environment = var.environment
  }
}

resource "aws_service_discovery_service" "grafana" {
  name = "grafana"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.main.id

    dns_records {
      ttl  = 10
      type = "A"
    }

    routing_policy = "MULTIVALUE"
  }

  health_check_custom_config {
    failure_threshold = 1
  }

  tags = {
    Name        = "grafana"
    Environment = var.environment
  }
}

# =============================================================================
# Outputs
# =============================================================================

output "namespace_id" {
  description = "CloudMap namespace ID"
  value       = aws_service_discovery_private_dns_namespace.main.id
}

output "namespace_name" {
  description = "CloudMap namespace name"
  value       = aws_service_discovery_private_dns_namespace.main.name
}

output "mimir_service_arn" {
  description = "Mimir service discovery ARN"
  value       = aws_service_discovery_service.mimir.arn
}

output "loki_service_arn" {
  description = "Loki service discovery ARN"
  value       = aws_service_discovery_service.loki.arn
}

output "tempo_service_arn" {
  description = "Tempo service discovery ARN"
  value       = aws_service_discovery_service.tempo.arn
}

output "pyroscope_service_arn" {
  description = "Pyroscope service discovery ARN"
  value       = aws_service_discovery_service.pyroscope.arn
}

output "grafana_service_arn" {
  description = "Grafana service discovery ARN"
  value       = aws_service_discovery_service.grafana.arn
}
