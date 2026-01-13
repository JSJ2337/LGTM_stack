# =============================================================================
# 05-CloudWatch-Logs Root Module - Variables
# =============================================================================

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "project_name" {
  description = "Project name"
  type        = string
}

variable "log_services" {
  description = "Map of services for log groups"
  type = map(object({
    retention_days = optional(number)
  }))
  default = {}
}

variable "log_retention_days" {
  description = "Default log retention in days"
  type        = number
  default     = 7
}

variable "tags" {
  description = "Additional tags for resources"
  type        = map(string)
  default     = {}
}
