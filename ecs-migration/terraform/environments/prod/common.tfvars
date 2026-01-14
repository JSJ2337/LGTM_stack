# =============================================================================
# Common Configuration - All Root Modules Share These Values
# =============================================================================
# 이 파일은 모든 루트 모듈에서 공통으로 사용하는 설정입니다.
# 각 루트 모듈에서 terraform apply -var-file="../common.tfvars" 로 사용합니다.
#
# 사용자 커스터마이징: 이 파일 하나만 수정하면 전체 인프라 설정 변경 가능
# =============================================================================

# -----------------------------------------------------------------------------
# 기본 설정
# -----------------------------------------------------------------------------

aws_region   = "ap-northeast-2"
environment  = "prod"
project_name = "lgtm"

# -----------------------------------------------------------------------------
# Terraform State Backend 설정
# terraform init -backend-config="bucket=$state_bucket" ... 로 사용
# -----------------------------------------------------------------------------

state_bucket       = "jsj-lgtm-terraform-state"
state_lock_table   = "jsj-lgtm-terraform-locks"

# -----------------------------------------------------------------------------
# 공통 태그
# -----------------------------------------------------------------------------

tags = {
  Owner      = "DevOps"
  CostCenter = "Engineering"
}

# -----------------------------------------------------------------------------
# VPC 네트워크 설정
# -----------------------------------------------------------------------------

vpc_cidr             = "10.0.0.0/16"
availability_zones   = ["ap-northeast-2a", "ap-northeast-2c"]
public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnet_cidrs = ["10.0.11.0/24", "10.0.12.0/24"]

# -----------------------------------------------------------------------------
# S3 스토리지 설정
# -----------------------------------------------------------------------------

s3_bucket_name = "jsj-lgtm-data-s3"

# -----------------------------------------------------------------------------
# ECR 설정
# -----------------------------------------------------------------------------

ecr_repositories = [
  "lgtm-mimir",
  "lgtm-loki",
  "lgtm-tempo",
  "lgtm-pyroscope",
  "lgtm-grafana",
  "lgtm-alloy"
]

ecr_image_tag_mutability           = "MUTABLE"
ecr_scan_on_push                   = true
ecr_lifecycle_policy_keep_count    = 30
ecr_lifecycle_policy_untagged_days = 7

# -----------------------------------------------------------------------------
# CloudMap 설정
# -----------------------------------------------------------------------------

cloudmap_namespace_name = "lgtm.local"
cloudmap_services       = ["mimir", "loki", "tempo", "pyroscope", "grafana", "alloy"]
cloudmap_dns_ttl        = 10

# -----------------------------------------------------------------------------
# ALB Ingress Rules
# 새로운 규칙 추가: 여기에 항목 추가하면 ALB SG에 자동 적용
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
  tempo_otlp = {
    from_port   = 4318
    to_port     = 4318
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Tempo OTLP HTTP access"
  }
}

# -----------------------------------------------------------------------------
# ECS Service Ports (Security Groups에서 사용)
# 새로운 서비스 포트 추가: 여기에 항목 추가하면 SG에 자동 적용
# - from_alb = true: ALB에서 들어오는 트래픽 허용
# - internal = true: 내부 통신 (ECS 간) 허용
# -----------------------------------------------------------------------------

ecs_service_ports = {
  # Grafana (ALB + 내부)
  grafana = {
    port        = 3000
    protocol    = "tcp"
    description = "Grafana HTTP"
    from_alb    = true
    internal    = false
  }
  # Mimir (ALB + 내부)
  mimir = {
    port        = 8080
    protocol    = "tcp"
    description = "Mimir HTTP"
    from_alb    = true
    internal    = true
  }
  mimir_grpc = {
    port        = 9095
    protocol    = "tcp"
    description = "Mimir gRPC"
    from_alb    = false
    internal    = true
  }
  # Loki (ALB + 내부)
  loki = {
    port        = 3100
    protocol    = "tcp"
    description = "Loki HTTP"
    from_alb    = true
    internal    = true
  }
  # Tempo (ALB + 내부)
  tempo = {
    port        = 3200
    protocol    = "tcp"
    description = "Tempo HTTP"
    from_alb    = true
    internal    = true
  }
  tempo_otlp_grpc = {
    port        = 4317
    protocol    = "tcp"
    description = "Tempo OTLP gRPC"
    from_alb    = true
    internal    = false
  }
  tempo_otlp_http = {
    port        = 4318
    protocol    = "tcp"
    description = "Tempo OTLP HTTP"
    from_alb    = true
    internal    = false
  }
  # Pyroscope (ALB + 내부)
  pyroscope = {
    port        = 4040
    protocol    = "tcp"
    description = "Pyroscope HTTP"
    from_alb    = true
    internal    = true
  }
  pyroscope_grpc = {
    port        = 4041
    protocol    = "tcp"
    description = "Pyroscope gRPC"
    from_alb    = false
    internal    = true
  }
  # Alloy (내부만)
  alloy = {
    port        = 12345
    protocol    = "tcp"
    description = "Alloy HTTP"
    from_alb    = false
    internal    = true
  }
  # Memberlist 클러스터링 (내부만)
  memberlist_tcp = {
    port        = 7946
    protocol    = "tcp"
    description = "Memberlist TCP"
    from_alb    = false
    internal    = true
  }
  memberlist_udp = {
    port        = 7946
    protocol    = "udp"
    description = "Memberlist UDP"
    from_alb    = false
    internal    = true
  }
}

# -----------------------------------------------------------------------------
# ALB 설정
# -----------------------------------------------------------------------------

alb_internal                   = false
alb_enable_deletion_protection = false
alb_certificate_arn            = ""

alb_health_check_config = {
  healthy_threshold   = 2
  unhealthy_threshold = 3
  timeout             = 5
  interval            = 30
}

# -----------------------------------------------------------------------------
# ECS 서비스 설정
# -----------------------------------------------------------------------------

service_config = {
  mimir = {
    cpu            = 1024
    memory         = 2048
    desired_count  = 1
    container_port = 8080
  }
  loki = {
    cpu            = 512
    memory         = 1024
    desired_count  = 1
    container_port = 3100
  }
  tempo = {
    cpu            = 512
    memory         = 1024
    desired_count  = 1
    container_port = 3200
  }
  pyroscope = {
    cpu            = 512
    memory         = 1024
    desired_count  = 1
    container_port = 4040
  }
  grafana = {
    cpu            = 512
    memory         = 1024
    desired_count  = 1
    container_port = 3000
  }
  alloy = {
    cpu            = 256
    memory         = 512
    desired_count  = 1
    container_port = 12345
  }
}

# -----------------------------------------------------------------------------
# Alloy Collector 설정
# -----------------------------------------------------------------------------

alloy_config = {
  loki_tenant  = "aws-rag-cloudwatch"
  mimir_tenant = "aws-rag-ec2"
}

# -----------------------------------------------------------------------------
# CloudWatch Logs 설정
# -----------------------------------------------------------------------------

log_retention_days = 7

log_services = {
  mimir     = {}
  loki      = {}
  tempo     = {}
  pyroscope = {}
  grafana   = {}
  alloy     = {}
}

# -----------------------------------------------------------------------------
# 이미지 버전 설정 (latest 사용 금지)
# Docker Compose (.env)와 동일한 버전으로 유지
# -----------------------------------------------------------------------------

image_versions = {
  mimir     = "2.16.0"
  loki      = "3.5.1"
  tempo     = "2.9.0"
  pyroscope = "1.13.5"
  grafana   = "12.1.0"
  alloy     = "1.9.2"
}

# -----------------------------------------------------------------------------
# 테넌트 설정
# -----------------------------------------------------------------------------

tenants = {
  default    = "jsj-lgtm"
  cloudflare = "jsj-cloudflare"
  rds        = "jsj-rds"
}
