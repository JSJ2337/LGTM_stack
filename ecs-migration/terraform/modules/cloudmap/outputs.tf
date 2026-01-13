# =============================================================================
# CloudMap Module - Outputs
# =============================================================================

output "namespace_id" {
  description = "CloudMap namespace ID"
  value       = aws_service_discovery_private_dns_namespace.main.id
}

output "namespace_arn" {
  description = "CloudMap namespace ARN"
  value       = aws_service_discovery_private_dns_namespace.main.arn
}

output "namespace_name" {
  description = "CloudMap namespace name"
  value       = aws_service_discovery_private_dns_namespace.main.name
}

output "service_arns" {
  description = "Map of service discovery ARNs"
  value       = { for k, v in aws_service_discovery_service.services : k => v.arn }
}

output "service_ids" {
  description = "Map of service discovery IDs"
  value       = { for k, v in aws_service_discovery_service.services : k => v.id }
}

# 개별 서비스 ARN (레거시 호환성)
output "mimir_service_arn" {
  description = "Mimir service discovery ARN"
  value       = try(aws_service_discovery_service.services["mimir"].arn, null)
}

output "loki_service_arn" {
  description = "Loki service discovery ARN"
  value       = try(aws_service_discovery_service.services["loki"].arn, null)
}

output "tempo_service_arn" {
  description = "Tempo service discovery ARN"
  value       = try(aws_service_discovery_service.services["tempo"].arn, null)
}

output "pyroscope_service_arn" {
  description = "Pyroscope service discovery ARN"
  value       = try(aws_service_discovery_service.services["pyroscope"].arn, null)
}

output "grafana_service_arn" {
  description = "Grafana service discovery ARN"
  value       = try(aws_service_discovery_service.services["grafana"].arn, null)
}

output "alloy_service_arn" {
  description = "Alloy service discovery ARN"
  value       = try(aws_service_discovery_service.services["alloy"].arn, null)
}
