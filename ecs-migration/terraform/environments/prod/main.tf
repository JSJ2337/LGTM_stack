# LGTM Stack ECS Fargate - Production Environment
# Terraform Main Configuration

terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # S3 Backend for State (권장)
  # backend "s3" {
  #   bucket         = "terraform-state-bucket"
  #   key            = "lgtm-ecs/terraform.tfstate"
  #   region         = "ap-northeast-2"
  #   encrypt        = true
  #   dynamodb_table = "terraform-locks"
  # }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "LGTM-Stack"
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  }
}

# =============================================================================
# Data Sources
# =============================================================================

data "aws_caller_identity" "current" {}

data "aws_vpc" "main" {
  filter {
    name   = "tag:Name"
    values = [var.vpc_name]
  }
}

data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.main.id]
  }

  filter {
    name   = "tag:Type"
    values = ["private"]
  }
}

data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.main.id]
  }

  filter {
    name   = "tag:Type"
    values = ["public"]
  }
}

# =============================================================================
# Modules
# =============================================================================

# ECR Repositories
module "ecr" {
  source = "../../modules/ecr"

  repositories = var.ecr_repositories
  environment  = var.environment
}

# IAM Roles
module "iam" {
  source = "../../modules/iam"

  environment    = var.environment
  s3_bucket_name = var.s3_bucket_name
}

# Security Groups
module "security_groups" {
  source = "../../modules/security-groups"

  vpc_id      = data.aws_vpc.main.id
  environment = var.environment
}

# CloudMap Service Discovery
module "cloudmap" {
  source = "../../modules/cloudmap"

  vpc_id      = data.aws_vpc.main.id
  environment = var.environment
  namespace   = var.cloudmap_namespace
}

# Application Load Balancer
module "alb" {
  source = "../../modules/alb"

  vpc_id             = data.aws_vpc.main.id
  public_subnet_ids  = data.aws_subnets.public.ids
  security_group_id  = module.security_groups.alb_security_group_id
  environment        = var.environment
  certificate_arn    = var.certificate_arn
  domain_name        = var.domain_name
}

# ECS Cluster & Services
module "ecs" {
  source = "../../modules/ecs"

  environment            = var.environment
  vpc_id                 = data.aws_vpc.main.id
  private_subnet_ids     = data.aws_subnets.private.ids
  security_group_id      = module.security_groups.ecs_security_group_id
  execution_role_arn     = module.iam.task_execution_role_arn
  cloudmap_namespace_id  = module.cloudmap.namespace_id
  ecr_repository_urls    = module.ecr.repository_urls
  aws_account_id         = data.aws_caller_identity.current.account_id
  aws_region             = var.aws_region

  # Task Roles
  mimir_task_role_arn     = module.iam.mimir_task_role_arn
  loki_task_role_arn      = module.iam.loki_task_role_arn
  tempo_task_role_arn     = module.iam.tempo_task_role_arn
  pyroscope_task_role_arn = module.iam.pyroscope_task_role_arn
  grafana_task_role_arn   = module.iam.grafana_task_role_arn
  alloy_task_role_arn     = module.iam.alloy_task_role_arn

  # ALB Target Groups
  mimir_target_group_arn    = module.alb.mimir_target_group_arn
  loki_target_group_arn     = module.alb.loki_target_group_arn
  tempo_target_group_arn    = module.alb.tempo_target_group_arn
  grafana_target_group_arn  = module.alb.grafana_target_group_arn

  # Service Configuration
  service_config = var.service_config
}

# =============================================================================
# Outputs
# =============================================================================

output "ecr_repository_urls" {
  description = "ECR repository URLs"
  value       = module.ecr.repository_urls
}

output "ecs_cluster_name" {
  description = "ECS Cluster name"
  value       = module.ecs.cluster_name
}

output "alb_dns_name" {
  description = "ALB DNS name"
  value       = module.alb.dns_name
}

output "cloudmap_namespace" {
  description = "CloudMap namespace"
  value       = module.cloudmap.namespace_name
}

output "grafana_url" {
  description = "Grafana URL"
  value       = "https://${var.domain_name}"
}
