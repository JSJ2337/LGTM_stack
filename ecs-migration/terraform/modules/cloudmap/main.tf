# =============================================================================
# CloudMap Module - Resources
# =============================================================================

# -----------------------------------------------------------------------------
# Private DNS Namespace
# -----------------------------------------------------------------------------

resource "aws_service_discovery_private_dns_namespace" "main" {
  name        = var.namespace_name
  description = "${var.project_name} Service Discovery Namespace"
  vpc         = var.vpc_id

  tags = merge(var.tags, {
    Name        = var.namespace_name
    Environment = var.environment
  })
}

# -----------------------------------------------------------------------------
# Service Discovery Services
# -----------------------------------------------------------------------------

resource "aws_service_discovery_service" "services" {
  for_each = toset(var.services)

  name = each.value

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.main.id

    dns_records {
      ttl  = var.dns_ttl
      type = "A"
    }

    routing_policy = "MULTIVALUE"
  }

  # ECS 태스크 헬스체크는 ECS에서 관리 (custom config 필수)
  health_check_custom_config {}

  tags = merge(var.tags, {
    Name        = each.value
    Environment = var.environment
  })
}
