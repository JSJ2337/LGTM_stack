# =============================================================================
# S3 Module - Variables
# =============================================================================

variable "bucket_name" {
  description = "S3 bucket name for LGTM storage"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "tags" {
  description = "Additional tags for resources"
  type        = map(string)
  default     = {}
}
