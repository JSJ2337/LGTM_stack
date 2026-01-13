# =============================================================================
# 10-ECR Root Module - Production Environment
# =============================================================================
# 실행 순서: 2번째 (종속성 없음, VPC와 병렬 가능)
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
    key = "lgtm-ecs/prod/10-ecr/terraform.tfstate"
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
# ECR Module
# -----------------------------------------------------------------------------

module "ecr" {
  source = "../../../modules/ecr"

  project_name                   = var.project_name
  environment                    = var.environment
  repositories                   = var.ecr_repositories
  image_tag_mutability           = var.ecr_image_tag_mutability
  scan_on_push                   = var.ecr_scan_on_push
  lifecycle_policy_keep_count    = var.ecr_lifecycle_policy_keep_count
  lifecycle_policy_untagged_days = var.ecr_lifecycle_policy_untagged_days
  tags                           = var.tags
}
