# =============================================================================
# Security Groups Module - Variables
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

variable "vpc_cidr" {
  description = "VPC CIDR block for internal traffic"
  type        = string
}

# -----------------------------------------------------------------------------
# ALB Security Group Configuration
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

# -----------------------------------------------------------------------------
# ECS Security Group Configuration
# -----------------------------------------------------------------------------

variable "ecs_service_ports" {
  description = "ECS service ports configuration"
  type = map(object({
    port        = number
    protocol    = string
    description = string
  }))
}

variable "tags" {
  description = "Additional tags for resources"
  type        = map(string)
  default     = {}
}
