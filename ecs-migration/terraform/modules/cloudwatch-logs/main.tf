# =============================================================================
# CloudWatch Logs Module - Resources
# =============================================================================
# ECS 서비스용 CloudWatch Log Groups 관리
# 라이프사이클: ECS와 독립적으로 관리 (로그 보존)
# =============================================================================

resource "aws_cloudwatch_log_group" "services" {
  for_each = var.services

  name              = "/ecs/${var.project_name}-${var.environment}/${each.key}"
  retention_in_days = lookup(each.value, "retention_days", var.default_retention_days)

  tags = merge(var.tags, {
    Name        = "/ecs/${var.project_name}-${var.environment}/${each.key}"
    Environment = var.environment
    Service     = each.key
  })
}
