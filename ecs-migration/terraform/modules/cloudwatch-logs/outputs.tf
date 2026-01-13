# =============================================================================
# CloudWatch Logs Module - Outputs
# =============================================================================

output "log_group_names" {
  description = "Map of service names to log group names"
  value = {
    for service, log_group in aws_cloudwatch_log_group.services :
    service => log_group.name
  }
}

output "log_group_arns" {
  description = "Map of service names to log group ARNs"
  value = {
    for service, log_group in aws_cloudwatch_log_group.services :
    service => log_group.arn
  }
}
