# =============================================================================
# IAM Module - Outputs
# =============================================================================

output "task_execution_role_arn" {
  description = "Task execution role ARN"
  value       = aws_iam_role.task_execution.arn
  sensitive   = true
}

output "task_execution_role_name" {
  description = "Task execution role name"
  value       = aws_iam_role.task_execution.name
}

output "mimir_task_role_arn" {
  description = "Mimir task role ARN (alias for lgtm_task_role_arn)"
  value       = aws_iam_role.lgtm_task.arn
  sensitive   = true
}

output "loki_task_role_arn" {
  description = "Loki task role ARN (alias for lgtm_task_role_arn)"
  value       = aws_iam_role.lgtm_task.arn
  sensitive   = true
}

output "tempo_task_role_arn" {
  description = "Tempo task role ARN (alias for lgtm_task_role_arn)"
  value       = aws_iam_role.lgtm_task.arn
  sensitive   = true
}

output "pyroscope_task_role_arn" {
  description = "Pyroscope task role ARN (alias for lgtm_task_role_arn)"
  value       = aws_iam_role.lgtm_task.arn
  sensitive   = true
}

output "grafana_task_role_arn" {
  description = "Grafana task role ARN"
  value       = aws_iam_role.grafana_task.arn
  sensitive   = true
}

output "alloy_task_role_arn" {
  description = "Alloy task role ARN"
  value       = aws_iam_role.alloy_task.arn
  sensitive   = true
}

output "lgtm_task_role_arn" {
  description = "LGTM shared task role ARN (Mimir, Loki, Tempo, Pyroscope)"
  value       = aws_iam_role.lgtm_task.arn
  sensitive   = true
}

output "lgtm_task_role_name" {
  description = "LGTM shared task role name"
  value       = aws_iam_role.lgtm_task.name
}

output "alloy_task_role_name" {
  description = "Alloy task role name"
  value       = aws_iam_role.alloy_task.name
}

output "grafana_task_role_name" {
  description = "Grafana task role name"
  value       = aws_iam_role.grafana_task.name
}
