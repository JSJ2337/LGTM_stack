# =============================================================================
# 40-CloudMap Root Module - Production Environment
# =============================================================================
# 실행 순서: 5번째
# 종속 모듈: 01-vpc (vpc_id 필요)
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
    key = "lgtm-ecs/prod/40-cloudmap/terraform.tfstate"
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
# Import: 기존 CloudMap 리소스 (state 손실 복구)
# -----------------------------------------------------------------------------

import {
  to = module.cloudmap.aws_service_discovery_private_dns_namespace.main
  id = "ns-rwp3nxccl4n4hg34"
}

import {
  to = module.cloudmap.aws_service_discovery_service.services["mimir"]
  id = "srv-obpplftauntdb6ih"
}

import {
  to = module.cloudmap.aws_service_discovery_service.services["loki"]
  id = "srv-3ikch4svmj4i6qa4"
}

import {
  to = module.cloudmap.aws_service_discovery_service.services["tempo"]
  id = "srv-ddsxjr2wa4igmzrv"
}

import {
  to = module.cloudmap.aws_service_discovery_service.services["pyroscope"]
  id = "srv-ligheqm4ghbngw2s"
}

import {
  to = module.cloudmap.aws_service_discovery_service.services["grafana"]
  id = "srv-6s2ocrn7r3xv6bwu"
}

import {
  to = module.cloudmap.aws_service_discovery_service.services["alloy"]
  id = "srv-psyee5im2w6siqdj"
}

# -----------------------------------------------------------------------------
# CloudMap Module
# -----------------------------------------------------------------------------

module "cloudmap" {
  source = "../../../modules/cloudmap"

  project_name   = var.project_name
  environment    = var.environment
  vpc_id         = data.terraform_remote_state.vpc.outputs.vpc_id
  namespace_name = var.cloudmap_namespace_name
  services       = var.cloudmap_services
  dns_ttl        = var.cloudmap_dns_ttl
  tags           = var.tags
}
