# LGTM Stack ECS Fargate - Terraform Variables
# Production Environment

aws_region   = "ap-northeast-2"
environment  = "prod"
project_name = "lgtm"

# S3 bucket for LGTM data storage
s3_bucket_name = "jsj-lgtm-training-s3"

# CloudMap namespace
cloudmap_namespace = "lgtm.local"

# VPC Configuration
vpc_cidr             = "10.0.0.0/16"
availability_zones   = ["ap-northeast-2a", "ap-northeast-2c"]
public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnet_cidrs = ["10.0.11.0/24", "10.0.12.0/24"]

# ACM Certificate (optional - leave empty for HTTP only)
certificate_arn = ""

# Domain name for Grafana (use ALB DNS if no custom domain)
domain_name = ""

# Service configuration (reduced for training/testing)
service_config = {
  mimir = {
    cpu            = 1024
    memory         = 2048
    desired_count  = 1
    container_port = 8080
  }
  loki = {
    cpu            = 512
    memory         = 1024
    desired_count  = 1
    container_port = 3100
  }
  tempo = {
    cpu            = 512
    memory         = 1024
    desired_count  = 1
    container_port = 3200
  }
  pyroscope = {
    cpu            = 512
    memory         = 1024
    desired_count  = 1
    container_port = 4040
  }
  grafana = {
    cpu            = 512
    memory         = 1024
    desired_count  = 1
    container_port = 3000
  }
  alloy = {
    cpu            = 256
    memory         = 512
    desired_count  = 1
    container_port = 12345
  }
}
