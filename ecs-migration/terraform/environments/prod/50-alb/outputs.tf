# =============================================================================
# 50-ALB Root Module - Outputs
# =============================================================================

output "alb_arn" {
  description = "ALB ARN"
  value       = module.alb.arn
}

output "alb_dns_name" {
  description = "ALB DNS name"
  value       = module.alb.dns_name
}

output "alb_zone_id" {
  description = "ALB zone ID"
  value       = module.alb.zone_id
}

output "target_group_arns" {
  description = "Map of service names to target group ARNs"
  value       = module.alb.target_group_arns
}

output "http_listener_arn" {
  description = "HTTP listener ARN"
  value       = module.alb.http_listener_arn
}

output "https_listener_arn" {
  description = "HTTPS listener ARN (if configured)"
  value       = module.alb.https_listener_arn
}
