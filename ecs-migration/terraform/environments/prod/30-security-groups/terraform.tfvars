# =============================================================================
# 30-Security Groups Root Module - Production Configuration
# =============================================================================
# 사용법: terraform apply -var-file="../common.tfvars" -var-file="terraform.tfvars"
# =============================================================================

# -----------------------------------------------------------------------------
# Remote State 설정
# -----------------------------------------------------------------------------

state_bucket = "jsj-lgtm-terraform-state"

# -----------------------------------------------------------------------------
# ALB Ingress Rules
# -----------------------------------------------------------------------------

alb_ingress_rules = {
  http = {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP access"
  }
  https = {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTPS access"
  }
}

# -----------------------------------------------------------------------------
# ECS Service Ports
# -----------------------------------------------------------------------------

ecs_service_ports = {
  grafana = {
    port        = 3000
    protocol    = "tcp"
    description = "Grafana HTTP"
  }
  mimir = {
    port        = 8080
    protocol    = "tcp"
    description = "Mimir HTTP"
  }
  mimir_grpc = {
    port        = 9095
    protocol    = "tcp"
    description = "Mimir gRPC"
  }
  loki = {
    port        = 3100
    protocol    = "tcp"
    description = "Loki HTTP"
  }
  tempo = {
    port        = 3200
    protocol    = "tcp"
    description = "Tempo HTTP"
  }
  tempo_otlp_grpc = {
    port        = 4317
    protocol    = "tcp"
    description = "Tempo OTLP gRPC"
  }
  tempo_otlp_http = {
    port        = 4318
    protocol    = "tcp"
    description = "Tempo OTLP HTTP"
  }
  pyroscope = {
    port        = 4040
    protocol    = "tcp"
    description = "Pyroscope HTTP"
  }
  pyroscope_grpc = {
    port        = 4041
    protocol    = "tcp"
    description = "Pyroscope gRPC"
  }
  alloy = {
    port        = 12345
    protocol    = "tcp"
    description = "Alloy HTTP"
  }
  memberlist_tcp = {
    port        = 7946
    protocol    = "tcp"
    description = "Memberlist TCP"
  }
  memberlist_udp = {
    port        = 7946
    protocol    = "udp"
    description = "Memberlist UDP"
  }
}
