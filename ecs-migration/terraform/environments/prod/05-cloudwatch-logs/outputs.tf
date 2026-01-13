# =============================================================================
# 05-CloudWatch-Logs Root Module - Outputs
# =============================================================================

output "log_group_names" {
  description = "Map of service names to log group names"
  value       = module.cloudwatch_logs.log_group_names
}

output "log_group_arns" {
  description = "Map of service names to log group ARNs"
  value       = module.cloudwatch_logs.log_group_arns
}
