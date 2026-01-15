# =============================================================================
# 35-ElastiCache Root Module - Variables
# =============================================================================

# -----------------------------------------------------------------------------
# Required Variables (from common.tfvars)
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
  description = "Project name"
  type        = string
}

variable "state_bucket" {
  description = "Terraform state S3 bucket name"
  type        = string
}

variable "state_lock_table" {
  description = "Terraform state DynamoDB lock table name"
  type        = string
}

variable "tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default     = {}
}

# -----------------------------------------------------------------------------
# Memcached Configuration
# -----------------------------------------------------------------------------

variable "memcached_config" {
  description = "ElastiCache Memcached configuration"
  type = object({
    version            = optional(string, "1.6.22")
    node_type          = optional(string, "cache.t3.micro")
    num_cache_nodes    = optional(number, 1)
    max_item_size      = optional(number, 1048576)
    maintenance_window = optional(string, "sun:05:00-sun:06:00")
  })
  default = {}
}
