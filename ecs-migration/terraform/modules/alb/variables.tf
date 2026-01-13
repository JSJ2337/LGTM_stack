# =============================================================================
# ALB Module - Variables
# =============================================================================

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "public_subnet_ids" {
  description = "Public subnet IDs for ALB"
  type        = list(string)
}

variable "security_group_id" {
  description = "ALB security group ID"
  type        = string
}

variable "certificate_arn" {
  description = "ACM certificate ARN for HTTPS (leave empty for HTTP only)"
  type        = string
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
}

variable "health_check_config" {
  description = "Health check configuration for target groups"
  type = object({
    healthy_threshold   = number
    unhealthy_threshold = number
    timeout             = number
    interval            = number
  })
}

variable "tags" {
  description = "Additional tags for resources"
  type        = map(string)
  default     = {}
}
