# =============================================================================
# Security Groups Module - Outputs
# =============================================================================

output "alb_security_group_id" {
  description = "ALB security group ID"
  value       = aws_security_group.alb.id
}

output "alb_security_group_arn" {
  description = "ALB security group ARN"
  value       = aws_security_group.alb.arn
}

output "ecs_security_group_id" {
  description = "ECS security group ID"
  value       = aws_security_group.ecs.id
}

output "ecs_security_group_arn" {
  description = "ECS security group ARN"
  value       = aws_security_group.ecs.arn
}
