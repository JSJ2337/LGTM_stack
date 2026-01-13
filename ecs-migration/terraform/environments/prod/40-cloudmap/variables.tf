# =============================================================================
# 40-CloudMap Root Module - Variables
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

# -----------------------------------------------------------------------------
# Remote State 설정
# -----------------------------------------------------------------------------

variable "state_bucket" {
  description = "Terraform state S3 bucket name"
  type        = string
}

# -----------------------------------------------------------------------------
# CloudMap 전용 변수
# -----------------------------------------------------------------------------

variable "cloudmap_namespace_name" {
  description = "CloudMap namespace name"
  type        = string
}

variable "cloudmap_services" {
  description = "List of service names for CloudMap"
  type        = list(string)
}

variable "cloudmap_dns_ttl" {
  description = "DNS record TTL in seconds"
  type        = number
}
