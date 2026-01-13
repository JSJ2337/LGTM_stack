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

variable "vpc_name" {
  description = "VPC Name tag"
  type        = string
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
  description = "ACM certificate ARN for HTTPS"
  type        = string
}

variable "domain_name" {
  description = "Domain name for Grafana"
  type        = string
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
