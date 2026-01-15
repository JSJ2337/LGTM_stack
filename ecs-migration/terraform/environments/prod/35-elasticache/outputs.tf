# =============================================================================
# 35-ElastiCache Root Module - Outputs
# =============================================================================

output "cluster_id" {
  description = "ElastiCache cluster ID"
  value       = module.elasticache.cluster_id
}

output "cluster_arn" {
  description = "ElastiCache cluster ARN"
  value       = module.elasticache.cluster_arn
}

output "configuration_endpoint" {
  description = "Memcached configuration endpoint (for auto-discovery)"
  value       = module.elasticache.configuration_endpoint
}

output "cluster_address" {
  description = "DNS name for the cache cluster"
  value       = module.elasticache.cluster_address
}

output "primary_endpoint" {
  description = "Primary node endpoint (address:port format)"
  value       = module.elasticache.primary_endpoint
}

output "port" {
  description = "Memcached port"
  value       = module.elasticache.port
}

output "security_group_id" {
  description = "Memcached security group ID"
  value       = module.elasticache.security_group_id
}
