# =============================================================================
# ECS Module - Outputs
# =============================================================================

output "cluster_name" {
  description = "ECS Cluster name"
  value       = aws_ecs_cluster.main.name
}

output "cluster_arn" {
  description = "ECS Cluster ARN"
  value       = aws_ecs_cluster.main.arn
}

output "cluster_id" {
  description = "ECS Cluster ID"
  value       = aws_ecs_cluster.main.id
}

output "mimir_service_name" {
  description = "Mimir ECS service name"
  value       = aws_ecs_service.mimir.name
}

output "loki_service_name" {
  description = "Loki ECS service name"
  value       = aws_ecs_service.loki.name
}

output "tempo_service_name" {
  description = "Tempo ECS service name"
  value       = aws_ecs_service.tempo.name
}

output "pyroscope_service_name" {
  description = "Pyroscope ECS service name"
  value       = aws_ecs_service.pyroscope.name
}

output "grafana_service_name" {
  description = "Grafana ECS service name"
  value       = aws_ecs_service.grafana.name
}

output "alloy_service_name" {
  description = "Alloy ECS service name"
  value       = aws_ecs_service.alloy.name
}

# Note: log_group_names output moved to cloudwatch-logs module
