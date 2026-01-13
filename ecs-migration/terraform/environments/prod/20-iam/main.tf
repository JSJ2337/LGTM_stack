# =============================================================================
# 20-IAM Root Module - Production Environment
# =============================================================================
# 실행 순서: 3번째 (종속성 없음, VPC/ECR과 병렬 가능)
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
    bucket         = "jsj-lgtm-terraform-state"
    key            = "lgtm-ecs/prod/20-iam/terraform.tfstate"
    region         = "ap-northeast-2"
    encrypt        = true
    dynamodb_table = "jsj-lgtm-terraform-locks"
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
# Data Source: AWS Account ID
# -----------------------------------------------------------------------------

data "aws_caller_identity" "current" {}

# -----------------------------------------------------------------------------
# IAM Module
# -----------------------------------------------------------------------------

module "iam" {
  source = "../../../modules/iam"

  project_name   = var.project_name
  environment    = var.environment
  s3_bucket_name = var.s3_bucket_name
  aws_region     = var.aws_region
  aws_account_id = data.aws_caller_identity.current.account_id
  tags           = var.tags
}
