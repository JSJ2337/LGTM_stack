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

output "service_names" {
  description = "Map of ECS service names"
  value       = module.ecs.service_names
}

output "task_definition_arns" {
  description = "Map of task definition ARNs"
  value       = module.ecs.task_definition_arns
}

output "log_group_names" {
  description = "Map of CloudWatch log group names"
  value       = module.ecs.log_group_names
}
