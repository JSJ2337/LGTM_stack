# =============================================================================
# ECR Module - Variables
# =============================================================================

variable "project_name" {
  description = "Project name for resource naming"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.project_name))
    error_message = "Project name must contain only lowercase letters, numbers, and hyphens."
  }
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
  }
}

variable "repositories" {
  description = "List of ECR repository names to create"
  type        = list(string)

  validation {
    condition     = length(var.repositories) > 0
    error_message = "At least one repository name must be provided."
  }

  validation {
    condition     = alltrue([for repo in var.repositories : can(regex("^[a-z0-9-/]+$", repo))])
    error_message = "Repository names must contain only lowercase letters, numbers, hyphens, and forward slashes."
  }
}

variable "image_tag_mutability" {
  description = "Image tag mutability (MUTABLE or IMMUTABLE)"
  type        = string

  validation {
    condition     = contains(["MUTABLE", "IMMUTABLE"], var.image_tag_mutability)
    error_message = "Image tag mutability must be either MUTABLE or IMMUTABLE."
  }
}

variable "scan_on_push" {
  description = "Enable image scanning on push"
  type        = bool
}

variable "lifecycle_policy_keep_count" {
  description = "Number of tagged images to keep"
  type        = number

  validation {
    condition     = var.lifecycle_policy_keep_count >= 1 && var.lifecycle_policy_keep_count <= 1000
    error_message = "Lifecycle policy keep count must be between 1 and 1000."
  }
}

variable "lifecycle_policy_untagged_days" {
  description = "Days to keep untagged images"
  type        = number

  validation {
    condition     = var.lifecycle_policy_untagged_days >= 1 && var.lifecycle_policy_untagged_days <= 365
    error_message = "Lifecycle policy untagged days must be between 1 and 365."
  }
}

variable "tags" {
  description = "Additional tags for resources"
  type        = map(string)
  default     = {}
}
