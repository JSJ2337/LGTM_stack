# =============================================================================
# 15-S3 Root Module - Variables
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

variable "s3_bucket_name" {
  description = "S3 bucket name for LGTM storage"
  type        = string
}

variable "tags" {
  description = "Additional tags for resources"
  type        = map(string)
  default     = {}
}
