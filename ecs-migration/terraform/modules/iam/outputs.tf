# =============================================================================
# IAM Module - Outputs
# =============================================================================

output "task_execution_role_arn" {
  description = "Task execution role ARN"
  value       = aws_iam_role.task_execution.arn
}

output "task_execution_role_name" {
  description = "Task execution role name"
  value       = aws_iam_role.task_execution.name
}

output "mimir_task_role_arn" {
  description = "Mimir task role ARN"
  value       = aws_iam_role.lgtm_task.arn
}

output "loki_task_role_arn" {
  description = "Loki task role ARN"
  value       = aws_iam_role.lgtm_task.arn
}

output "tempo_task_role_arn" {
  description = "Tempo task role ARN"
  value       = aws_iam_role.lgtm_task.arn
}

output "pyroscope_task_role_arn" {
  description = "Pyroscope task role ARN"
  value       = aws_iam_role.lgtm_task.arn
}

output "grafana_task_role_arn" {
  description = "Grafana task role ARN"
  value       = aws_iam_role.grafana_task.arn
}

output "alloy_task_role_arn" {
  description = "Alloy task role ARN"
  value       = aws_iam_role.alloy_task.arn
}

output "lgtm_task_role_arn" {
  description = "LGTM shared task role ARN (Mimir, Loki, Tempo, Pyroscope)"
  value       = aws_iam_role.lgtm_task.arn
}
