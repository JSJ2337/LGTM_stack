# =============================================================================
# ALB Module - Variables
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

variable "public_subnet_ids" {
  description = "Public subnet IDs for ALB"
  type        = list(string)

  validation {
    condition     = length(var.public_subnet_ids) >= 2
    error_message = "At least 2 public subnets are required for ALB high availability."
  }

  validation {
    condition     = alltrue([for id in var.public_subnet_ids : can(regex("^subnet-[a-f0-9]+$", id))])
    error_message = "All subnet IDs must be valid AWS subnet IDs (e.g., subnet-12345678)."
  }
}

variable "security_group_id" {
  description = "ALB security group ID"
  type        = string

  validation {
    condition     = can(regex("^sg-[a-f0-9]+$", var.security_group_id))
    error_message = "Security group ID must be a valid AWS security group ID (e.g., sg-12345678)."
  }
}

variable "certificate_arn" {
  description = "ACM certificate ARN for HTTPS (leave empty for HTTP only)"
  type        = string

  validation {
    condition     = var.certificate_arn == "" || can(regex("^arn:aws:acm:[a-z0-9-]+:[0-9]{12}:certificate/[a-f0-9-]+$", var.certificate_arn))
    error_message = "Certificate ARN must be empty or a valid ACM certificate ARN."
  }
}

variable "domain_name" {
  description = "Domain name for Grafana (optional)"
  type        = string
  default     = ""
}

variable "internal" {
  description = "Whether the ALB is internal"
  type        = bool
}

variable "enable_deletion_protection" {
  description = "Enable deletion protection for ALB"
  type        = bool
}

variable "service_config" {
  description = "Service configuration for target groups"
  type = map(object({
    cpu            = number
    memory         = number
    desired_count  = number
    container_port = number
  }))

  validation {
    condition = alltrue([
      for svc in values(var.service_config) :
      contains([256, 512, 1024, 2048, 4096, 8192, 16384], svc.cpu)
    ])
    error_message = "CPU must be a valid Fargate value: 256, 512, 1024, 2048, 4096, 8192, or 16384."
  }

  validation {
    condition = alltrue([
      for svc in values(var.service_config) :
      svc.memory >= 512 && svc.memory <= 122880
    ])
    error_message = "Memory must be between 512 and 122880 MB."
  }

  validation {
    condition = alltrue([
      for svc in values(var.service_config) :
      svc.desired_count >= 0
    ])
    error_message = "Desired count must be 0 or greater."
  }

  validation {
    condition = alltrue([
      for svc in values(var.service_config) :
      svc.container_port >= 1 && svc.container_port <= 65535
    ])
    error_message = "Container port must be between 1 and 65535."
  }
}

variable "health_check_config" {
  description = "Health check configuration for target groups"
  type = object({
    healthy_threshold   = number
    unhealthy_threshold = number
    timeout             = number
    interval            = number
  })

  validation {
    condition     = var.health_check_config.healthy_threshold >= 2 && var.health_check_config.healthy_threshold <= 10
    error_message = "Healthy threshold must be between 2 and 10."
  }

  validation {
    condition     = var.health_check_config.unhealthy_threshold >= 2 && var.health_check_config.unhealthy_threshold <= 10
    error_message = "Unhealthy threshold must be between 2 and 10."
  }

  validation {
    condition     = var.health_check_config.timeout >= 2 && var.health_check_config.timeout <= 120
    error_message = "Timeout must be between 2 and 120 seconds."
  }

  validation {
    condition     = var.health_check_config.interval >= 5 && var.health_check_config.interval <= 300
    error_message = "Interval must be between 5 and 300 seconds."
  }

  validation {
    condition     = var.health_check_config.timeout < var.health_check_config.interval
    error_message = "Timeout must be less than interval."
  }
}

variable "tags" {
  description = "Additional tags for resources"
  type        = map(string)
  default     = {}
}
