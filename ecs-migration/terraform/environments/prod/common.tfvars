# =============================================================================
# Common Configuration - All Root Modules Share These Values
# =============================================================================
# 이 파일은 모든 루트 모듈에서 공통으로 사용하는 설정입니다.
# 각 루트 모듈에서 terraform apply -var-file="../common.tfvars" 로 사용합니다.
# =============================================================================

# -----------------------------------------------------------------------------
# 기본 설정
# -----------------------------------------------------------------------------

aws_region   = "ap-northeast-2"
environment  = "prod"
project_name = "lgtm"

# -----------------------------------------------------------------------------
# Terraform State Backend 설정 (참조용)
# -----------------------------------------------------------------------------
# 각 루트 모듈의 backend 설정에서 사용
# bucket         = "jsj-lgtm-terraform-state"
# region         = "ap-northeast-2"
# dynamodb_table = "jsj-lgtm-terraform-locks"

# -----------------------------------------------------------------------------
# 공통 태그
# -----------------------------------------------------------------------------

tags = {
  Owner      = "DevOps"
  CostCenter = "Engineering"
}

# -----------------------------------------------------------------------------
# S3 스토리지 설정
# -----------------------------------------------------------------------------

s3_bucket_name = "jsj-lgtm-training-s3"

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
