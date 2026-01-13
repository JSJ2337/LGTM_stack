# =============================================================================
# Security Groups Module - Variables
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

variable "vpc_cidr" {
  description = "VPC CIDR block for internal traffic"
  type        = string

  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "VPC CIDR must be a valid IPv4 CIDR block (e.g., 10.0.0.0/16)."
  }
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

  validation {
    condition = alltrue([
      for rule in values(var.alb_ingress_rules) :
      rule.from_port >= 0 && rule.from_port <= 65535 &&
      rule.to_port >= 0 && rule.to_port <= 65535
    ])
    error_message = "Port numbers must be between 0 and 65535."
  }

  validation {
    condition = alltrue([
      for rule in values(var.alb_ingress_rules) :
      contains(["tcp", "udp", "icmp", "-1"], rule.protocol)
    ])
    error_message = "Protocol must be one of: tcp, udp, icmp, -1 (all)."
  }
}

# -----------------------------------------------------------------------------
# ECS Security Group Configuration
# -----------------------------------------------------------------------------

variable "ecs_service_ports" {
  description = "ECS service ports configuration. from_alb과 internal 속성으로 규칙 유형 제어"
  type = map(object({
    port        = number
    protocol    = string
    description = string
    from_alb    = optional(bool, false)
    internal    = optional(bool, false)
  }))

  validation {
    condition = alltrue([
      for svc in values(var.ecs_service_ports) :
      svc.port >= 1 && svc.port <= 65535
    ])
    error_message = "Service ports must be between 1 and 65535."
  }

  validation {
    condition = alltrue([
      for svc in values(var.ecs_service_ports) :
      contains(["tcp", "udp"], svc.protocol)
    ])
    error_message = "Protocol must be either tcp or udp."
  }
}

variable "tags" {
  description = "Additional tags for resources"
  type        = map(string)
  default     = {}
}
