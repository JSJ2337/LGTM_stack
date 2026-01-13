# =============================================================================
# 05-CloudWatch-Logs Root Module - Production Environment
# =============================================================================
# 실행 순서: 2번째 (VPC와 병렬 가능, ECS보다 먼저)
# 종속 모듈: 없음
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
    key = "lgtm-ecs/prod/05-cloudwatch-logs/terraform.tfstate"
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
# CloudWatch Logs Module
# -----------------------------------------------------------------------------

module "cloudwatch_logs" {
  source = "../../../modules/cloudwatch-logs"

  project_name           = var.project_name
  environment            = var.environment
  services               = var.log_services
  default_retention_days = var.log_retention_days
  tags                   = var.tags
}
