# =============================================================================
# 15-S3 Root Module - Production Environment
# =============================================================================
# 실행 순서: 2번째 (VPC와 병렬 가능)
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
    key = "lgtm-ecs/prod/15-s3/terraform.tfstate"
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
# S3 Module
# -----------------------------------------------------------------------------

module "s3" {
  source = "../../../modules/s3"

  bucket_name = var.s3_bucket_name
  environment = var.environment
  tags        = var.tags
}
