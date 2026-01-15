# =============================================================================
# ElastiCache Module - Outputs
# =============================================================================

output "cluster_id" {
  description = "ElastiCache cluster ID"
  value       = aws_elasticache_cluster.memcached.cluster_id
}

output "cluster_arn" {
  description = "ElastiCache cluster ARN"
  value       = aws_elasticache_cluster.memcached.arn
}

output "configuration_endpoint" {
  description = "Memcached configuration endpoint (for auto-discovery)"
  value       = aws_elasticache_cluster.memcached.configuration_endpoint
}

output "cluster_address" {
  description = "DNS name for the cache cluster"
  value       = aws_elasticache_cluster.memcached.cluster_address
}

output "cache_nodes" {
  description = "List of cache node details"
  value       = aws_elasticache_cluster.memcached.cache_nodes
}

output "port" {
  description = "Memcached port"
  value       = 11211
}

# 단일 노드인 경우 첫 번째 노드의 엔드포인트 반환
output "primary_endpoint" {
  description = "Primary node endpoint (address:port format for config files)"
  value       = "${aws_elasticache_cluster.memcached.cache_nodes[0].address}:11211"
}

output "security_group_id" {
  description = "Memcached security group ID"
  value       = aws_security_group.memcached.id
}

output "subnet_group_name" {
  description = "ElastiCache subnet group name"
  value       = aws_elasticache_subnet_group.main.name
}
