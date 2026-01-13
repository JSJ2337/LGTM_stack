# =============================================================================
# 60-ECS Root Module - Outputs
# =============================================================================

output "cluster_id" {
  description = "ECS Cluster ID"
  value       = module.ecs.cluster_id
}

output "cluster_arn" {
  description = "ECS Cluster ARN"
  value       = module.ecs.cluster_arn
}

output "cluster_name" {
  description = "ECS Cluster Name"
  value       = module.ecs.cluster_name
}

output "mimir_service_name" {
  description = "Mimir ECS service name"
  value       = module.ecs.mimir_service_name
}

output "loki_service_name" {
  description = "Loki ECS service name"
  value       = module.ecs.loki_service_name
}

output "tempo_service_name" {
  description = "Tempo ECS service name"
  value       = module.ecs.tempo_service_name
}

output "pyroscope_service_name" {
  description = "Pyroscope ECS service name"
  value       = module.ecs.pyroscope_service_name
}

output "grafana_service_name" {
  description = "Grafana ECS service name"
  value       = module.ecs.grafana_service_name
}

output "alloy_service_name" {
  description = "Alloy ECS service name"
  value       = module.ecs.alloy_service_name
}
