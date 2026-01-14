# =============================================================================
# ALB Module - Outputs
# =============================================================================

output "arn" {
  description = "ALB ARN"
  value       = aws_lb.main.arn
}

output "id" {
  description = "ALB ID"
  value       = aws_lb.main.id
}

output "dns_name" {
  description = "ALB DNS name"
  value       = aws_lb.main.dns_name
}

output "zone_id" {
  description = "ALB zone ID for Route53"
  value       = aws_lb.main.zone_id
}

output "grafana_target_group_arn" {
  description = "Grafana target group ARN"
  value       = aws_lb_target_group.grafana.arn
}

output "mimir_target_group_arn" {
  description = "Mimir target group ARN"
  value       = aws_lb_target_group.mimir.arn
}

output "loki_target_group_arn" {
  description = "Loki target group ARN"
  value       = aws_lb_target_group.loki.arn
}

output "tempo_target_group_arn" {
  description = "Tempo target group ARN"
  value       = aws_lb_target_group.tempo.arn
}

output "pyroscope_target_group_arn" {
  description = "Pyroscope target group ARN"
  value       = aws_lb_target_group.pyroscope.arn
}

# Map 형태의 target group ARN (권장)
output "target_group_arns" {
  description = "Map of all target group ARNs"
  value = {
    grafana    = aws_lb_target_group.grafana.arn
    mimir      = aws_lb_target_group.mimir.arn
    loki       = aws_lb_target_group.loki.arn
    tempo      = aws_lb_target_group.tempo.arn
    tempo_otlp = aws_lb_target_group.tempo_otlp.arn
    pyroscope  = aws_lb_target_group.pyroscope.arn
  }
}

output "tempo_otlp_target_group_arn" {
  description = "Tempo OTLP target group ARN"
  value       = aws_lb_target_group.tempo_otlp.arn
}

output "http_listener_arn" {
  description = "HTTP listener ARN"
  value       = aws_lb_listener.http.arn
}

output "https_listener_arn" {
  description = "HTTPS listener ARN (null if HTTPS is disabled)"
  value       = local.enable_https ? aws_lb_listener.https[0].arn : null
}
