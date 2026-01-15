# =============================================================================
# 35-ElastiCache Root Module - Production Environment
# =============================================================================
# 실행 순서: 5번째 (30-security-groups 이후, 40-cloudmap 이전)
# 종속 모듈: 01-vpc (vpc_id, private_subnet_ids 필요)
#           30-security-groups (ecs_security_group_id 필요)
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
    key = "lgtm-ecs/prod/35-elasticache/terraform.tfstate"
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
# ElastiCache Module
# -----------------------------------------------------------------------------

module "elasticache" {
  source = "../../../modules/elasticache"

  project_name          = var.project_name
  environment           = var.environment
  vpc_id                = data.terraform_remote_state.vpc.outputs.vpc_id
  private_subnet_ids    = data.terraform_remote_state.vpc.outputs.private_subnet_ids
  ecs_security_group_id = data.terraform_remote_state.security_groups.outputs.ecs_security_group_id

  # Memcached Configuration
  memcached_version  = var.memcached_config.version
  node_type          = var.memcached_config.node_type
  num_cache_nodes    = var.memcached_config.num_cache_nodes
  max_item_size      = var.memcached_config.max_item_size
  maintenance_window = var.memcached_config.maintenance_window

  tags = var.tags
}
