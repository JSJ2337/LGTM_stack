# LGTM Stack ECS Fargate - Variables

variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "ap-northeast-2"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "prod"
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "lgtm"
}

# =============================================================================
# VPC Configuration
# =============================================================================

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
  default     = ["ap-northeast-2a", "ap-northeast-2c"]
}

variable "public_subnet_cidrs" {
  description = "Public subnet CIDR blocks"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "Private subnet CIDR blocks"
  type        = list(string)
  default     = ["10.0.11.0/24", "10.0.12.0/24"]
}

variable "s3_bucket_name" {
  description = "S3 bucket for LGTM data storage"
  type        = string
  default     = "sys-lgtm-s3"
}

variable "cloudmap_namespace" {
  description = "CloudMap namespace for service discovery"
  type        = string
  default     = "lgtm.local"
}

variable "certificate_arn" {
  description = "ACM certificate ARN for HTTPS (optional - leave empty for HTTP only)"
  type        = string
  default     = ""
}

variable "domain_name" {
  description = "Domain name for Grafana (optional - uses ALB DNS if empty)"
  type        = string
  default     = ""
}

variable "ecr_repositories" {
  description = "List of ECR repository names"
  type        = list(string)
  default = [
    "lgtm-mimir",
    "lgtm-loki",
    "lgtm-tempo",
    "lgtm-pyroscope",
    "lgtm-grafana",
    "lgtm-alloy"
  ]
}

variable "service_config" {
  description = "ECS service configuration"
  type = map(object({
    cpu           = number
    memory        = number
    desired_count = number
    container_port = number
  }))
  default = {
    mimir = {
      cpu           = 2048
      memory        = 4096
      desired_count = 3
      container_port = 8080
    }
    loki = {
      cpu           = 1024
      memory        = 2048
      desired_count = 2
      container_port = 3100
    }
    tempo = {
      cpu           = 1024
      memory        = 2048
      desired_count = 1
      container_port = 3200
    }
    pyroscope = {
      cpu           = 1024
      memory        = 2048
      desired_count = 1
      container_port = 4040
    }
    grafana = {
      cpu           = 512
      memory        = 1024
      desired_count = 1
      container_port = 3000
    }
    alloy = {
      cpu           = 512
      memory        = 1024
      desired_count = 1
      container_port = 12345
    }
  }
}
