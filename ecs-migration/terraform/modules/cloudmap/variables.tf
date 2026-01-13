# =============================================================================
# CloudMap Module - Variables
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

variable "vpc_id" {
  description = "VPC ID"
  type        = string

  validation {
    condition     = can(regex("^vpc-[a-f0-9]+$", var.vpc_id))
    error_message = "VPC ID must be a valid AWS VPC ID (e.g., vpc-12345678)."
  }
}

variable "namespace_name" {
  description = "CloudMap namespace name"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9.-]*[a-z0-9]$", var.namespace_name))
    error_message = "Namespace name must be a valid DNS name (e.g., lgtm.local)."
  }
}

variable "services" {
  description = "List of service names to register"
  type        = list(string)

  validation {
    condition     = length(var.services) > 0
    error_message = "At least one service must be provided."
  }

  validation {
    condition     = alltrue([for svc in var.services : can(regex("^[a-z0-9-]+$", svc))])
    error_message = "Service names must contain only lowercase letters, numbers, and hyphens."
  }
}

variable "dns_ttl" {
  description = "DNS record TTL in seconds"
  type        = number

  validation {
    condition     = var.dns_ttl >= 1 && var.dns_ttl <= 86400
    error_message = "DNS TTL must be between 1 and 86400 seconds (24 hours)."
  }
}

variable "tags" {
  description = "Additional tags for resources"
  type        = map(string)
  default     = {}
}
