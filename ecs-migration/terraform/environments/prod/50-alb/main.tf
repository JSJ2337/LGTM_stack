# =============================================================================
# 50-ALB Root Module - Production Environment
# =============================================================================
# 실행 순서: 6번째
# 종속 모듈: 01-vpc (vpc_id, public_subnet_ids), 30-security-groups (alb_sg_id)
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
    key = "lgtm-ecs/prod/50-alb/terraform.tfstate"
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

data "terraform_remote_state" "security_groups" {
  backend = "s3"

  config = {
    bucket = var.state_bucket
    key    = "lgtm-ecs/prod/30-security-groups/terraform.tfstate"
    region = var.aws_region
  }
}

# -----------------------------------------------------------------------------
# ALB Module
# -----------------------------------------------------------------------------

module "alb" {
  source = "../../../modules/alb"

  project_name               = var.project_name
  environment                = var.environment
  vpc_id                     = data.terraform_remote_state.vpc.outputs.vpc_id
  public_subnet_ids          = data.terraform_remote_state.vpc.outputs.public_subnet_ids
  security_group_id          = data.terraform_remote_state.security_groups.outputs.alb_security_group_id
  internal                   = var.alb_internal
  enable_deletion_protection = var.alb_enable_deletion_protection
  certificate_arn            = var.alb_certificate_arn
  service_config             = var.service_config
  health_check_config        = var.alb_health_check_config
  tags                       = var.tags
}
