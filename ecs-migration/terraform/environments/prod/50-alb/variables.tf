# =============================================================================
# 50-ALB Root Module - Variables
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
  description = "Project name for resource naming"
  type        = string
}

variable "tags" {
  description = "Additional tags for resources"
  type        = map(string)
  default     = {}
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

# -----------------------------------------------------------------------------
# Remote State 설정
# -----------------------------------------------------------------------------

variable "state_bucket" {
  description = "Terraform state S3 bucket name"
  type        = string
}

# -----------------------------------------------------------------------------
# ALB 전용 변수
# -----------------------------------------------------------------------------

variable "alb_internal" {
  description = "Whether the ALB is internal"
  type        = bool
}

variable "alb_enable_deletion_protection" {
  description = "Enable deletion protection for ALB"
  type        = bool
}

variable "alb_certificate_arn" {
  description = "ACM certificate ARN for HTTPS"
  type        = string
}

variable "alb_health_check_config" {
  description = "Health check configuration"
  type = object({
    healthy_threshold   = number
    unhealthy_threshold = number
    timeout             = number
    interval            = number
  })
}
