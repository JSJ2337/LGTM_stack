# ECS Module - LGTM Stack

variable "environment" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "security_group_id" {
  type = string
}

variable "execution_role_arn" {
  type = string
}

variable "cloudmap_namespace_id" {
  type = string
}

variable "ecr_repository_urls" {
  type = map(string)
}

variable "aws_account_id" {
  type = string
}

variable "aws_region" {
  type = string
}

variable "mimir_task_role_arn" {
  type = string
}

variable "loki_task_role_arn" {
  type = string
}

variable "tempo_task_role_arn" {
  type = string
}

variable "pyroscope_task_role_arn" {
  type = string
}

variable "grafana_task_role_arn" {
  type = string
}

variable "alloy_task_role_arn" {
  type = string
}

variable "mimir_target_group_arn" {
  type = string
}

variable "loki_target_group_arn" {
  type = string
}

variable "tempo_target_group_arn" {
  type = string
}

variable "grafana_target_group_arn" {
  type = string
}

variable "service_config" {
  type = map(object({
    cpu            = number
    memory         = number
    desired_count  = number
    container_port = number
  }))
}

# =============================================================================
# ECS Cluster
# =============================================================================

resource "aws_ecs_cluster" "main" {
  name = "lgtm-${var.environment}-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = {
    Name        = "lgtm-${var.environment}-cluster"
    Environment = var.environment
  }
}

resource "aws_ecs_cluster_capacity_providers" "main" {
  cluster_name = aws_ecs_cluster.main.name

  capacity_providers = ["FARGATE", "FARGATE_SPOT"]

  default_capacity_provider_strategy {
    base              = 1
    weight            = 1
    capacity_provider = "FARGATE"
  }

  default_capacity_provider_strategy {
    weight            = 4
    capacity_provider = "FARGATE_SPOT"
  }
}

# =============================================================================
# CloudWatch Log Groups
# =============================================================================

resource "aws_cloudwatch_log_group" "services" {
  for_each = toset(["mimir", "loki", "tempo", "pyroscope", "grafana", "alloy"])

  name              = "/ecs/lgtm-${each.key}"
  retention_in_days = 7

  tags = {
    Name        = "/ecs/lgtm-${each.key}"
    Environment = var.environment
  }
}

# =============================================================================
# Task Definitions
# =============================================================================

# Mimir Task Definition
resource "aws_ecs_task_definition" "mimir" {
  family                   = "lgtm-mimir"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.service_config.mimir.cpu
  memory                   = var.service_config.mimir.memory
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.mimir_task_role_arn

  container_definitions = jsonencode([
    {
      name      = "mimir"
      image     = "${var.ecr_repository_urls["lgtm-mimir"]}:latest"
      essential = true

      portMappings = [
        { containerPort = 8080, protocol = "tcp", name = "http" },
        { containerPort = 9095, protocol = "tcp", name = "grpc" },
        { containerPort = 7946, protocol = "tcp", name = "memberlist" }
      ]

      environment = [
        { name = "AWS_REGION", value = var.aws_region },
        { name = "MIMIR_S3_BUCKET", value = "sys-lgtm-s3" }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/lgtm-mimir"
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "mimir"
        }
      }

      healthCheck = {
        command     = ["CMD-SHELL", "curl -f http://localhost:8080/-/ready || exit 1"]
        interval    = 30
        timeout     = 10
        retries     = 3
        startPeriod = 60
      }

      stopTimeout = 120
    }
  ])

  tags = {
    Name        = "lgtm-mimir"
    Environment = var.environment
  }
}

# Loki Task Definition
resource "aws_ecs_task_definition" "loki" {
  family                   = "lgtm-loki"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.service_config.loki.cpu
  memory                   = var.service_config.loki.memory
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.loki_task_role_arn

  container_definitions = jsonencode([
    {
      name      = "loki"
      image     = "${var.ecr_repository_urls["lgtm-loki"]}:latest"
      essential = true

      portMappings = [
        { containerPort = 3100, protocol = "tcp", name = "http" },
        { containerPort = 7946, protocol = "tcp", name = "memberlist" }
      ]

      environment = [
        { name = "AWS_REGION", value = var.aws_region },
        { name = "LOKI_S3_BUCKET", value = "sys-lgtm-s3" }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/lgtm-loki"
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "loki"
        }
      }

      healthCheck = {
        command     = ["CMD-SHELL", "wget --no-verbose --tries=1 --spider http://localhost:3100/ready || exit 1"]
        interval    = 30
        timeout     = 10
        retries     = 3
        startPeriod = 40
      }

      stopTimeout = 120
    }
  ])

  tags = {
    Name        = "lgtm-loki"
    Environment = var.environment
  }
}

# Tempo Task Definition
resource "aws_ecs_task_definition" "tempo" {
  family                   = "lgtm-tempo"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.service_config.tempo.cpu
  memory                   = var.service_config.tempo.memory
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.tempo_task_role_arn

  container_definitions = jsonencode([
    {
      name      = "tempo"
      image     = "${var.ecr_repository_urls["lgtm-tempo"]}:latest"
      essential = true

      portMappings = [
        { containerPort = 3200, protocol = "tcp", name = "http" },
        { containerPort = 4317, protocol = "tcp", name = "otlp-grpc" },
        { containerPort = 4318, protocol = "tcp", name = "otlp-http" }
      ]

      environment = [
        { name = "AWS_REGION", value = var.aws_region }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/lgtm-tempo"
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "tempo"
        }
      }

      healthCheck = {
        command     = ["CMD-SHELL", "curl -f http://localhost:3200/ready || exit 1"]
        interval    = 30
        timeout     = 10
        retries     = 3
        startPeriod = 30
      }

      stopTimeout = 120
    }
  ])

  tags = {
    Name        = "lgtm-tempo"
    Environment = var.environment
  }
}

# Pyroscope Task Definition
resource "aws_ecs_task_definition" "pyroscope" {
  family                   = "lgtm-pyroscope"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.service_config.pyroscope.cpu
  memory                   = var.service_config.pyroscope.memory
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.pyroscope_task_role_arn

  container_definitions = jsonencode([
    {
      name      = "pyroscope"
      image     = "${var.ecr_repository_urls["lgtm-pyroscope"]}:latest"
      essential = true

      portMappings = [
        { containerPort = 4040, protocol = "tcp", name = "http" },
        { containerPort = 4041, protocol = "tcp", name = "grpc" }
      ]

      environment = [
        { name = "AWS_REGION", value = var.aws_region },
        { name = "TZ", value = "Asia/Seoul" }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/lgtm-pyroscope"
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "pyroscope"
        }
      }

      healthCheck = {
        command     = ["CMD-SHELL", "curl -f http://localhost:4040/ready || exit 1"]
        interval    = 30
        timeout     = 10
        retries     = 3
        startPeriod = 30
      }

      stopTimeout = 120
    }
  ])

  tags = {
    Name        = "lgtm-pyroscope"
    Environment = var.environment
  }
}

# Grafana Task Definition
resource "aws_ecs_task_definition" "grafana" {
  family                   = "lgtm-grafana"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.service_config.grafana.cpu
  memory                   = var.service_config.grafana.memory
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.grafana_task_role_arn

  container_definitions = jsonencode([
    {
      name      = "grafana"
      image     = "${var.ecr_repository_urls["lgtm-grafana"]}:latest"
      essential = true

      portMappings = [
        { containerPort = 3000, protocol = "tcp", name = "http" }
      ]

      environment = [
        { name = "GF_SECURITY_ADMIN_USER", value = "admin" },
        { name = "GF_USERS_ALLOW_SIGN_UP", value = "false" },
        { name = "GF_LOG_LEVEL", value = "info" },
        { name = "GF_DATE_FORMATS_DEFAULT_TIMEZONE", value = "Asia/Seoul" },
        { name = "TZ", value = "Asia/Seoul" }
      ]

      secrets = [
        {
          name      = "GF_SECURITY_ADMIN_PASSWORD"
          valueFrom = "arn:aws:secretsmanager:${var.aws_region}:${var.aws_account_id}:secret:lgtm/grafana-admin-password"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/lgtm-grafana"
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "grafana"
        }
      }

      healthCheck = {
        command     = ["CMD-SHELL", "curl -f http://localhost:3000/api/health || exit 1"]
        interval    = 30
        timeout     = 10
        retries     = 3
        startPeriod = 60
      }

      stopTimeout = 30
    }
  ])

  tags = {
    Name        = "lgtm-grafana"
    Environment = var.environment
  }
}

# Alloy Task Definition
resource "aws_ecs_task_definition" "alloy" {
  family                   = "lgtm-alloy"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.service_config.alloy.cpu
  memory                   = var.service_config.alloy.memory
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.alloy_task_role_arn

  container_definitions = jsonencode([
    {
      name      = "alloy"
      image     = "${var.ecr_repository_urls["lgtm-alloy"]}:latest"
      essential = true

      portMappings = [
        { containerPort = 12345, protocol = "tcp", name = "http" },
        { containerPort = 9080, protocol = "tcp", name = "metrics" }
      ]

      environment = [
        { name = "LOKI_URL", value = "http://loki.lgtm.local:3100/loki/api/v1/push" },
        { name = "LOKI_TENANT", value = "ftt-cloudflare" },
        { name = "MIMIR_URL", value = "http://mimir.lgtm.local:8080/api/v1/push" },
        { name = "MIMIR_TENANT", value = "ftt-lgtm-rds" }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/lgtm-alloy"
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "alloy"
        }
      }

      healthCheck = {
        command     = ["CMD-SHELL", "wget -qO- http://localhost:12345/-/healthy >/dev/null 2>&1 || exit 1"]
        interval    = 30
        timeout     = 10
        retries     = 3
        startPeriod = 30
      }

      stopTimeout = 30
    }
  ])

  tags = {
    Name        = "lgtm-alloy"
    Environment = var.environment
  }
}

# =============================================================================
# ECS Services
# =============================================================================

# Mimir Service
resource "aws_ecs_service" "mimir" {
  name            = "mimir"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.mimir.arn
  desired_count   = var.service_config.mimir.desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [var.security_group_id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.mimir_target_group_arn
    container_name   = "mimir"
    container_port   = 8080
  }

  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 100

  tags = {
    Name        = "mimir"
    Environment = var.environment
  }

  lifecycle {
    ignore_changes = [desired_count]
  }
}

# Loki Service
resource "aws_ecs_service" "loki" {
  name            = "loki"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.loki.arn
  desired_count   = var.service_config.loki.desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [var.security_group_id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.loki_target_group_arn
    container_name   = "loki"
    container_port   = 3100
  }

  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 100

  tags = {
    Name        = "loki"
    Environment = var.environment
  }

  lifecycle {
    ignore_changes = [desired_count]
  }
}

# Tempo Service
resource "aws_ecs_service" "tempo" {
  name            = "tempo"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.tempo.arn
  desired_count   = var.service_config.tempo.desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [var.security_group_id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.tempo_target_group_arn
    container_name   = "tempo"
    container_port   = 3200
  }

  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 100

  tags = {
    Name        = "tempo"
    Environment = var.environment
  }

  lifecycle {
    ignore_changes = [desired_count]
  }
}

# Pyroscope Service
resource "aws_ecs_service" "pyroscope" {
  name            = "pyroscope"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.pyroscope.arn
  desired_count   = var.service_config.pyroscope.desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [var.security_group_id]
    assign_public_ip = false
  }

  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 100

  tags = {
    Name        = "pyroscope"
    Environment = var.environment
  }

  lifecycle {
    ignore_changes = [desired_count]
  }
}

# Grafana Service
resource "aws_ecs_service" "grafana" {
  name            = "grafana"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.grafana.arn
  desired_count   = var.service_config.grafana.desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [var.security_group_id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.grafana_target_group_arn
    container_name   = "grafana"
    container_port   = 3000
  }

  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 100

  tags = {
    Name        = "grafana"
    Environment = var.environment
  }

  lifecycle {
    ignore_changes = [desired_count]
  }
}

# Alloy Service
resource "aws_ecs_service" "alloy" {
  name            = "alloy"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.alloy.arn
  desired_count   = var.service_config.alloy.desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [var.security_group_id]
    assign_public_ip = false
  }

  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 100

  tags = {
    Name        = "alloy"
    Environment = var.environment
  }

  lifecycle {
    ignore_changes = [desired_count]
  }
}

# =============================================================================
# Outputs
# =============================================================================

output "cluster_name" {
  description = "ECS Cluster name"
  value       = aws_ecs_cluster.main.name
}

output "cluster_arn" {
  description = "ECS Cluster ARN"
  value       = aws_ecs_cluster.main.arn
}
