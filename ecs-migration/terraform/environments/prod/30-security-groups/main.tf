# =============================================================================
# 30-Security Groups Root Module - Production Environment
# =============================================================================
# 실행 순서: 4번째
# 종속 모듈: 01-vpc (vpc_id, vpc_cidr 필요)
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
    key            = "lgtm-ecs/prod/30-security-groups/terraform.tfstate"
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
# Data Source: VPC State
# -----------------------------------------------------------------------------

data "terraform_remote_state" "vpc" {
  backend = "s3"

  config = {
    bucket = var.state_bucket
    key    = "lgtm-ecs/prod/01-vpc/terraform.tfstate"
    region = var.aws_region
  }
}

# -----------------------------------------------------------------------------
# Security Groups Module
# -----------------------------------------------------------------------------

module "security_groups" {
  source = "../../../modules/security-groups"

  project_name      = var.project_name
  environment       = var.environment
  vpc_id            = data.terraform_remote_state.vpc.outputs.vpc_id
  vpc_cidr          = data.terraform_remote_state.vpc.outputs.vpc_cidr
  alb_ingress_rules = var.alb_ingress_rules
  ecs_service_ports = var.ecs_service_ports
  tags              = var.tags
}
