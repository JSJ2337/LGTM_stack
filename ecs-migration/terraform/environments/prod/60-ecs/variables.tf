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

# -----------------------------------------------------------------------------
# Image Versions (latest 사용 금지)
# -----------------------------------------------------------------------------

variable "image_versions" {
  description = "Image versions for each service"
  type = object({
    mimir     = string
    loki      = string
    tempo     = string
    pyroscope = string
    grafana   = string
    alloy     = string
  })

  default = {
    mimir     = "2.16.0"
    loki      = "3.5.1"
    tempo     = "2.9.0"
    pyroscope = "1.13.5"
    grafana   = "12.1.0"
    alloy     = "1.9.2"
  }
}

# -----------------------------------------------------------------------------
# Tenant Configuration
# -----------------------------------------------------------------------------

variable "tenants" {
  description = "Tenant IDs for multi-tenancy"
  type = object({
    default    = string
    cloudflare = string
    rds        = string
  })

  default = {
    default    = "jsj-lgtm"
    cloudflare = "jsj-cloudflare"
    rds        = "jsj-rds"
  }
}

# -----------------------------------------------------------------------------
# S3 Storage Prefix 설정
# -----------------------------------------------------------------------------

variable "storage_prefixes" {
  description = "S3 storage prefixes for each service"
  type = object({
    loki      = string
    tempo     = string
    pyroscope = string
  })

  default = {
    loki      = "loki"
    tempo     = "tempo"
    pyroscope = "pyroscope"
  }
}
