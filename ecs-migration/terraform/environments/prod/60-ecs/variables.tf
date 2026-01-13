# =============================================================================
# 60-ECS Root Module - Variables
# =============================================================================

# -----------------------------------------------------------------------------
# 공통 변수 (common.tfvars에서 가져옴)
# -----------------------------------------------------------------------------

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
}

variable "tags" {
  description = "Additional tags for resources"
  type        = map(string)
  default     = {}
}

variable "s3_bucket_name" {
  description = "S3 bucket name for LGTM storage"
  type        = string
}

variable "service_config" {
  description = "ECS service configuration"
  type = map(object({
    cpu            = number
    memory         = number
    desired_count  = number
    container_port = number
  }))
}

# -----------------------------------------------------------------------------
# Remote State 설정
# -----------------------------------------------------------------------------

variable "state_bucket" {
  description = "Terraform state S3 bucket name"
  type        = string
}

# -----------------------------------------------------------------------------
# ECS 전용 변수
# -----------------------------------------------------------------------------

variable "alloy_config" {
  description = "Alloy collector configuration"
  type = object({
    loki_tenant  = string
    mimir_tenant = string
  })
}
