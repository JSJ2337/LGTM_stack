# =============================================================================
# ECS Module - Variables
# =============================================================================

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "aws_account_id" {
  description = "AWS Account ID"
  type        = string
}

# -----------------------------------------------------------------------------
# Network Configuration
# -----------------------------------------------------------------------------

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for ECS tasks"
  type        = list(string)
}

variable "security_group_id" {
  description = "ECS security group ID"
  type        = string
}

# -----------------------------------------------------------------------------
# IAM Configuration
# -----------------------------------------------------------------------------

variable "execution_role_arn" {
  description = "ECS task execution role ARN"
  type        = string
}

variable "mimir_task_role_arn" {
  description = "Mimir task role ARN"
  type        = string
}

variable "loki_task_role_arn" {
  description = "Loki task role ARN"
  type        = string
}

variable "tempo_task_role_arn" {
  description = "Tempo task role ARN"
  type        = string
}

variable "pyroscope_task_role_arn" {
  description = "Pyroscope task role ARN"
  type        = string
}

variable "grafana_task_role_arn" {
  description = "Grafana task role ARN"
  type        = string
}

variable "alloy_task_role_arn" {
  description = "Alloy task role ARN"
  type        = string
}

# -----------------------------------------------------------------------------
# Service Discovery
# -----------------------------------------------------------------------------

variable "cloudmap_namespace_id" {
  description = "CloudMap namespace ID"
  type        = string
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
}

variable "loki_target_group_arn" {
  description = "Loki ALB target group ARN"
  type        = string
}

variable "tempo_target_group_arn" {
  description = "Tempo ALB target group ARN"
  type        = string
}

variable "grafana_target_group_arn" {
  description = "Grafana ALB target group ARN"
  type        = string
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
}

variable "s3_bucket_name" {
  description = "S3 bucket name for LGTM data storage"
  type        = string
}

variable "log_retention_days" {
  description = "CloudWatch Logs retention in days"
  type        = number
}

variable "tags" {
  description = "Additional tags for resources"
  type        = map(string)
  default     = {}
}
