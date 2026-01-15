# =============================================================================
# ECS Module - Variables
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

variable "aws_region" {
  description = "AWS region"
  type        = string

  validation {
    condition     = can(regex("^[a-z]{2}-[a-z]+-[0-9]+$", var.aws_region))
    error_message = "AWS region must be a valid region format (e.g., ap-northeast-2, us-east-1)."
  }
}

variable "aws_account_id" {
  description = "AWS Account ID"
  type        = string
  sensitive   = true

  validation {
    condition     = can(regex("^[0-9]{12}$", var.aws_account_id))
    error_message = "AWS Account ID must be exactly 12 digits."
  }
}

# -----------------------------------------------------------------------------
# Network Configuration
# -----------------------------------------------------------------------------

variable "vpc_id" {
  description = "VPC ID"
  type        = string

  validation {
    condition     = can(regex("^vpc-[a-f0-9]+$", var.vpc_id))
    error_message = "VPC ID must be a valid AWS VPC ID (e.g., vpc-12345678)."
  }
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for ECS tasks"
  type        = list(string)

  validation {
    condition     = length(var.private_subnet_ids) >= 2
    error_message = "At least 2 private subnets are required for ECS high availability."
  }

  validation {
    condition     = alltrue([for id in var.private_subnet_ids : can(regex("^subnet-[a-f0-9]+$", id))])
    error_message = "All subnet IDs must be valid AWS subnet IDs (e.g., subnet-12345678)."
  }
}

variable "security_group_id" {
  description = "ECS security group ID"
  type        = string

  validation {
    condition     = can(regex("^sg-[a-f0-9]+$", var.security_group_id))
    error_message = "Security group ID must be a valid AWS security group ID (e.g., sg-12345678)."
  }
}

# -----------------------------------------------------------------------------
# IAM Configuration
# -----------------------------------------------------------------------------

variable "execution_role_arn" {
  description = "ECS task execution role ARN"
  type        = string
  sensitive   = true

  validation {
    condition     = can(regex("^arn:aws:iam::[0-9]{12}:role/.+$", var.execution_role_arn))
    error_message = "Execution role ARN must be a valid IAM role ARN."
  }
}

variable "mimir_task_role_arn" {
  description = "Mimir task role ARN"
  type        = string
  sensitive   = true

  validation {
    condition     = can(regex("^arn:aws:iam::[0-9]{12}:role/.+$", var.mimir_task_role_arn))
    error_message = "Task role ARN must be a valid IAM role ARN."
  }
}

variable "loki_task_role_arn" {
  description = "Loki task role ARN"
  type        = string
  sensitive   = true

  validation {
    condition     = can(regex("^arn:aws:iam::[0-9]{12}:role/.+$", var.loki_task_role_arn))
    error_message = "Task role ARN must be a valid IAM role ARN."
  }
}

variable "tempo_task_role_arn" {
  description = "Tempo task role ARN"
  type        = string
  sensitive   = true

  validation {
    condition     = can(regex("^arn:aws:iam::[0-9]{12}:role/.+$", var.tempo_task_role_arn))
    error_message = "Task role ARN must be a valid IAM role ARN."
  }
}

variable "pyroscope_task_role_arn" {
  description = "Pyroscope task role ARN"
  type        = string
  sensitive   = true

  validation {
    condition     = can(regex("^arn:aws:iam::[0-9]{12}:role/.+$", var.pyroscope_task_role_arn))
    error_message = "Task role ARN must be a valid IAM role ARN."
  }
}

variable "grafana_task_role_arn" {
  description = "Grafana task role ARN"
  type        = string
  sensitive   = true

  validation {
    condition     = can(regex("^arn:aws:iam::[0-9]{12}:role/.+$", var.grafana_task_role_arn))
    error_message = "Task role ARN must be a valid IAM role ARN."
  }
}

variable "alloy_task_role_arn" {
  description = "Alloy task role ARN"
  type        = string
  sensitive   = true

  validation {
    condition     = can(regex("^arn:aws:iam::[0-9]{12}:role/.+$", var.alloy_task_role_arn))
    error_message = "Task role ARN must be a valid IAM role ARN."
  }
}

# -----------------------------------------------------------------------------
# Service Discovery
# -----------------------------------------------------------------------------

variable "cloudmap_service_arns" {
  description = "Map of CloudMap service ARNs (from cloudmap module)"
  type        = map(string)
}

# -----------------------------------------------------------------------------
# ECR Configuration
# -----------------------------------------------------------------------------

variable "ecr_repository_urls" {
  description = "Map of ECR repository URLs"
  type        = map(string)
}

# -----------------------------------------------------------------------------
# ALB Target Groups
# -----------------------------------------------------------------------------

variable "mimir_target_group_arn" {
  description = "Mimir ALB target group ARN"
  type        = string

  validation {
    condition     = can(regex("^arn:aws:elasticloadbalancing:[a-z0-9-]+:[0-9]{12}:targetgroup/.+$", var.mimir_target_group_arn))
    error_message = "Target group ARN must be a valid ALB target group ARN."
  }
}

variable "loki_target_group_arn" {
  description = "Loki ALB target group ARN"
  type        = string

  validation {
    condition     = can(regex("^arn:aws:elasticloadbalancing:[a-z0-9-]+:[0-9]{12}:targetgroup/.+$", var.loki_target_group_arn))
    error_message = "Target group ARN must be a valid ALB target group ARN."
  }
}

variable "tempo_target_group_arn" {
  description = "Tempo ALB target group ARN"
  type        = string

  validation {
    condition     = can(regex("^arn:aws:elasticloadbalancing:[a-z0-9-]+:[0-9]{12}:targetgroup/.+$", var.tempo_target_group_arn))
    error_message = "Target group ARN must be a valid ALB target group ARN."
  }
}

variable "grafana_target_group_arn" {
  description = "Grafana ALB target group ARN"
  type        = string

  validation {
    condition     = can(regex("^arn:aws:elasticloadbalancing:[a-z0-9-]+:[0-9]{12}:targetgroup/.+$", var.grafana_target_group_arn))
    error_message = "Target group ARN must be a valid ALB target group ARN."
  }
}

variable "pyroscope_target_group_arn" {
  description = "Pyroscope ALB target group ARN"
  type        = string

  validation {
    condition     = can(regex("^arn:aws:elasticloadbalancing:[a-z0-9-]+:[0-9]{12}:targetgroup/.+$", var.pyroscope_target_group_arn))
    error_message = "Target group ARN must be a valid ALB target group ARN."
  }
}

# -----------------------------------------------------------------------------
# Service Configuration
# -----------------------------------------------------------------------------

variable "service_config" {
  description = "ECS service configuration"
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

variable "s3_bucket_name" {
  description = "S3 bucket name for LGTM data storage"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9.-]{1,61}[a-z0-9]$", var.s3_bucket_name))
    error_message = "S3 bucket name must be 3-63 characters, start and end with letter/number, contain only lowercase letters, numbers, hyphens, and periods."
  }
}

variable "log_group_names" {
  description = "Map of service names to CloudWatch Log Group names (from cloudwatch-logs module)"
  type        = map(string)
}

variable "tags" {
  description = "Additional tags for resources"
  type        = map(string)
  default     = {}
}

# -----------------------------------------------------------------------------
# Alloy Configuration
# -----------------------------------------------------------------------------

variable "alloy_config" {
  description = "Alloy collector configuration"
  type = object({
    loki_tenant  = string
    mimir_tenant = string
  })

  validation {
    condition     = length(var.alloy_config.loki_tenant) > 0 && length(var.alloy_config.mimir_tenant) > 0
    error_message = "Alloy config must have non-empty loki_tenant and mimir_tenant values."
  }
}

variable "cloudmap_namespace_name" {
  description = "CloudMap namespace name for service discovery (e.g., lgtm.local)"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9.-]*[a-z0-9]$", var.cloudmap_namespace_name))
    error_message = "Namespace name must be a valid DNS name (e.g., lgtm.local)."
  }
}

# -----------------------------------------------------------------------------
# Image Versions (latest 사용 금지)
# -----------------------------------------------------------------------------

variable "image_versions" {
  description = "Image versions for each service (Docker Compose .env와 동일하게 유지)"
  type = object({
    mimir     = string
    loki      = string
    tempo     = string
    pyroscope = string
    grafana   = string
    alloy     = string
  })

  default = {
    mimir     = "2.16.0"
    loki      = "3.5.1"
    tempo     = "2.9.0"
    pyroscope = "1.13.5"
    grafana   = "12.1.0"
    alloy     = "1.9.2"
  }
}

# -----------------------------------------------------------------------------
# Tenant Configuration
# -----------------------------------------------------------------------------

variable "tenants" {
  description = "Tenant IDs for multi-tenancy"
  type = object({
    default    = string
    cloudflare = string
    rds        = string
  })

  default = {
    default    = "jsj-lgtm"
    cloudflare = "jsj-cloudflare"
    rds        = "jsj-rds"
  }
}
