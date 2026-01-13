# =============================================================================
# 30-Security Groups Root Module - Variables
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

# -----------------------------------------------------------------------------
# Remote State 설정
# -----------------------------------------------------------------------------

variable "state_bucket" {
  description = "Terraform state S3 bucket name"
  type        = string
}

# -----------------------------------------------------------------------------
# Security Groups 전용 변수
# -----------------------------------------------------------------------------

variable "alb_ingress_rules" {
  description = "ALB ingress rules"
  type = map(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
    description = string
  }))
}

variable "ecs_service_ports" {
  description = "ECS service ports for internal communication"
  type = map(object({
    port        = number
    protocol    = string
    description = string
  }))
}
