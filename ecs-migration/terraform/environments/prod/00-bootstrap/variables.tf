# =============================================================================
# 00-Bootstrap Root Module - Variables
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
  description = "Project name"
  type        = string
}

# -----------------------------------------------------------------------------
# Bootstrap 전용 변수 (common.tfvars에서 가져옴)
# -----------------------------------------------------------------------------

variable "state_bucket" {
  description = "S3 bucket name for Terraform state"
  type        = string
}

variable "state_lock_table" {
  description = "DynamoDB table name for state locking"
  type        = string
}
