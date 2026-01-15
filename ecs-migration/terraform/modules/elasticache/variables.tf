# =============================================================================
# ElastiCache Module - Variables
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

variable "private_subnet_ids" {
  description = "List of private subnet IDs for ElastiCache"
  type        = list(string)

  validation {
    condition     = length(var.private_subnet_ids) >= 1
    error_message = "At least one private subnet ID is required."
  }
}

variable "ecs_security_group_id" {
  description = "ECS security group ID to allow access from"
  type        = string

  validation {
    condition     = can(regex("^sg-[a-f0-9]+$", var.ecs_security_group_id))
    error_message = "Security group ID must be a valid AWS security group ID."
  }
}

# -----------------------------------------------------------------------------
# Memcached Configuration
# -----------------------------------------------------------------------------

variable "memcached_version" {
  description = "Memcached engine version"
  type        = string
  default     = "1.6.22"
}

variable "node_type" {
  description = "ElastiCache node type"
  type        = string
  default     = "cache.t3.micro"

  validation {
    condition     = can(regex("^cache\\.", var.node_type))
    error_message = "Node type must start with 'cache.' prefix."
  }
}

variable "num_cache_nodes" {
  description = "Number of cache nodes (1 for single-az, 2+ for cross-az)"
  type        = number
  default     = 1

  validation {
    condition     = var.num_cache_nodes >= 1 && var.num_cache_nodes <= 40
    error_message = "Number of cache nodes must be between 1 and 40."
  }
}

variable "max_item_size" {
  description = "Maximum item size in bytes (default: 1MB = 1048576)"
  type        = number
  default     = 1048576

  validation {
    condition     = var.max_item_size >= 1024 && var.max_item_size <= 134217728
    error_message = "Max item size must be between 1KB and 128MB."
  }
}

variable "maintenance_window" {
  description = "Maintenance window (UTC)"
  type        = string
  default     = "sun:05:00-sun:06:00"
}

variable "sns_topic_arn" {
  description = "SNS topic ARN for notifications (optional)"
  type        = string
  default     = null
}

variable "tags" {
  description = "Additional tags for resources"
  type        = map(string)
  default     = {}
}
