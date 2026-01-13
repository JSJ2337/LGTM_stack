# =============================================================================
# 60-ECS Root Module - Production Environment
# =============================================================================
# 실행 순서: 8번째 (마지막)
# 종속 모듈: 01-vpc, 05-cloudwatch-logs, 10-ecr, 20-iam, 30-security-groups,
#           40-cloudmap, 50-alb
# =============================================================================

terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    key = "lgtm-ecs/prod/60-ecs/terraform.tfstate"
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  }
}

# -----------------------------------------------------------------------------
# Data Sources: Remote States
# -----------------------------------------------------------------------------

data "terraform_remote_state" "vpc" {
  backend = "s3"

  config = {
    bucket = var.state_bucket
    key    = "lgtm-ecs/prod/01-vpc/terraform.tfstate"
    region = var.aws_region
  }
}

data "terraform_remote_state" "ecr" {
  backend = "s3"

  config = {
    bucket = var.state_bucket
    key    = "lgtm-ecs/prod/10-ecr/terraform.tfstate"
    region = var.aws_region
  }
}

data "terraform_remote_state" "iam" {
  backend = "s3"

  config = {
    bucket = var.state_bucket
    key    = "lgtm-ecs/prod/20-iam/terraform.tfstate"
    region = var.aws_region
  }
}

data "terraform_remote_state" "security_groups" {
  backend = "s3"

  config = {
    bucket = var.state_bucket
    key    = "lgtm-ecs/prod/30-security-groups/terraform.tfstate"
    region = var.aws_region
  }
}

data "terraform_remote_state" "cloudmap" {
  backend = "s3"

  config = {
    bucket = var.state_bucket
    key    = "lgtm-ecs/prod/40-cloudmap/terraform.tfstate"
    region = var.aws_region
  }
}

data "terraform_remote_state" "alb" {
  backend = "s3"

  config = {
    bucket = var.state_bucket
    key    = "lgtm-ecs/prod/50-alb/terraform.tfstate"
    region = var.aws_region
  }
}

data "terraform_remote_state" "cloudwatch_logs" {
  backend = "s3"

  config = {
    bucket = var.state_bucket
    key    = "lgtm-ecs/prod/05-cloudwatch-logs/terraform.tfstate"
    region = var.aws_region
  }
}

# -----------------------------------------------------------------------------
# Data Source: AWS Account ID
# -----------------------------------------------------------------------------

data "aws_caller_identity" "current" {}

# -----------------------------------------------------------------------------
# ECS Module
# -----------------------------------------------------------------------------

module "ecs" {
  source = "../../../modules/ecs"

  project_name   = var.project_name
  environment    = var.environment
  aws_region     = var.aws_region
  aws_account_id = data.aws_caller_identity.current.account_id

  # Network
  vpc_id             = data.terraform_remote_state.vpc.outputs.vpc_id
  private_subnet_ids = data.terraform_remote_state.vpc.outputs.private_subnet_ids
  security_group_id  = data.terraform_remote_state.security_groups.outputs.ecs_security_group_id

  # IAM
  execution_role_arn      = data.terraform_remote_state.iam.outputs.task_execution_role_arn
  mimir_task_role_arn     = data.terraform_remote_state.iam.outputs.lgtm_task_role_arn
  loki_task_role_arn      = data.terraform_remote_state.iam.outputs.lgtm_task_role_arn
  tempo_task_role_arn     = data.terraform_remote_state.iam.outputs.lgtm_task_role_arn
  pyroscope_task_role_arn = data.terraform_remote_state.iam.outputs.lgtm_task_role_arn
  grafana_task_role_arn   = data.terraform_remote_state.iam.outputs.grafana_task_role_arn
  alloy_task_role_arn     = data.terraform_remote_state.iam.outputs.alloy_task_role_arn

  # Service Discovery (CloudMap 모듈에서 생성한 서비스 ARN 사용)
  cloudmap_service_arns   = data.terraform_remote_state.cloudmap.outputs.service_arns
  cloudmap_namespace_name = data.terraform_remote_state.cloudmap.outputs.namespace_name

  # ECR
  ecr_repository_urls = data.terraform_remote_state.ecr.outputs.repository_urls

  # ALB Target Groups
  mimir_target_group_arn     = data.terraform_remote_state.alb.outputs.target_group_arns["mimir"]
  loki_target_group_arn      = data.terraform_remote_state.alb.outputs.target_group_arns["loki"]
  tempo_target_group_arn     = data.terraform_remote_state.alb.outputs.target_group_arns["tempo"]
  grafana_target_group_arn   = data.terraform_remote_state.alb.outputs.target_group_arns["grafana"]
  pyroscope_target_group_arn = data.terraform_remote_state.alb.outputs.target_group_arns["pyroscope"]

  # Service Configuration
  service_config  = var.service_config
  s3_bucket_name  = var.s3_bucket_name
  log_group_names = data.terraform_remote_state.cloudwatch_logs.outputs.log_group_names

  # Alloy Configuration
  alloy_config = var.alloy_config

  tags = var.tags
}
