# =============================================================================
# 20-IAM Root Module - Outputs
# =============================================================================

output "task_execution_role_arn" {
  description = "ECS Task Execution Role ARN"
  value       = module.iam.task_execution_role_arn
  sensitive   = true
}

output "task_execution_role_name" {
  description = "ECS Task Execution Role Name"
  value       = module.iam.task_execution_role_name
}

output "lgtm_task_role_arn" {
  description = "LGTM Task Role ARN (S3 access)"
  value       = module.iam.lgtm_task_role_arn
  sensitive   = true
}

output "lgtm_task_role_name" {
  description = "LGTM Task Role Name"
  value       = module.iam.lgtm_task_role_name
}

output "alloy_task_role_arn" {
  description = "Alloy Task Role ARN (CloudWatch access)"
  value       = module.iam.alloy_task_role_arn
  sensitive   = true
}

output "alloy_task_role_name" {
  description = "Alloy Task Role Name"
  value       = module.iam.alloy_task_role_name
}

output "grafana_task_role_arn" {
  description = "Grafana Task Role ARN"
  value       = module.iam.grafana_task_role_arn
  sensitive   = true
}

output "grafana_task_role_name" {
  description = "Grafana Task Role Name"
  value       = module.iam.grafana_task_role_name
}
