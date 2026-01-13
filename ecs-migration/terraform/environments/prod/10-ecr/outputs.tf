# =============================================================================
# 10-ECR Root Module - Outputs
# =============================================================================

output "repository_urls" {
  description = "Map of repository names to URLs"
  value       = module.ecr.repository_urls
}

output "repository_arns" {
  description = "Map of repository names to ARNs"
  value       = module.ecr.repository_arns
}
