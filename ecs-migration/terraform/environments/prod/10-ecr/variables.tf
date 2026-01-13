# =============================================================================
# 10-ECR Root Module - Variables
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
# ECR 전용 변수
# -----------------------------------------------------------------------------

variable "repositories" {
  description = "List of ECR repository names"
  type        = list(string)
}

variable "image_tag_mutability" {
  description = "Image tag mutability setting"
  type        = string
}

variable "scan_on_push" {
  description = "Enable image scanning on push"
  type        = bool
}

variable "lifecycle_policy_keep_count" {
  description = "Number of tagged images to keep"
  type        = number
}

variable "lifecycle_policy_untagged_days" {
  description = "Days to keep untagged images"
  type        = number
}
