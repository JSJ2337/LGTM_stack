# =============================================================================
# ECR Module - Variables
# =============================================================================

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
}

variable "repositories" {
  description = "List of ECR repository names to create"
  type        = list(string)
}

variable "image_tag_mutability" {
  description = "Image tag mutability (MUTABLE or IMMUTABLE)"
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

variable "tags" {
  description = "Additional tags for resources"
  type        = map(string)
  default     = {}
}
