# =============================================================================
# 30-Security Groups Root Module - Outputs
# =============================================================================

output "alb_security_group_id" {
  description = "ALB Security Group ID"
  value       = module.security_groups.alb_security_group_id
}

output "ecs_security_group_id" {
  description = "ECS Tasks Security Group ID"
  value       = module.security_groups.ecs_security_group_id
}
