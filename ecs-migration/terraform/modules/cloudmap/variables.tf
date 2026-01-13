# =============================================================================
# CloudMap Module - Variables
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

variable "namespace_name" {
  description = "CloudMap namespace name"
  type        = string
}

variable "services" {
  description = "List of service names to register"
  type        = list(string)
}

variable "dns_ttl" {
  description = "DNS record TTL in seconds"
  type        = number
}

variable "tags" {
  description = "Additional tags for resources"
  type        = map(string)
  default     = {}
}
