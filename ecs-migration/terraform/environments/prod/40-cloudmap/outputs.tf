# =============================================================================
# 40-CloudMap Root Module - Outputs
# =============================================================================

output "namespace_id" {
  description = "CloudMap namespace ID"
  value       = module.cloudmap.namespace_id
}

output "namespace_arn" {
  description = "CloudMap namespace ARN"
  value       = module.cloudmap.namespace_arn
}

output "namespace_name" {
  description = "CloudMap namespace name"
  value       = module.cloudmap.namespace_name
}

output "service_arns" {
  description = "Map of service names to ARNs"
  value       = module.cloudmap.service_arns
}

output "service_ids" {
  description = "Map of service names to IDs"
  value       = module.cloudmap.service_ids
}
