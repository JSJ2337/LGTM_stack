# =============================================================================
# ECS Module - Resources
# =============================================================================

locals {
  services = ["mimir", "loki", "tempo", "pyroscope", "grafana", "alloy"]
}

# =============================================================================
# ECS Cluster
# =============================================================================

resource "aws_ecs_cluster" "main" {
  name = "${var.project_name}-${var.environment}-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = merge(var.tags, {
    Name        = "${var.project_name}-${var.environment}-cluster"
    Environment = var.environment
  })
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
# Task Definitions
# =============================================================================
# Note: CloudWatch Log Groups are managed by cloudwatch-logs module
# =============================================================================

# Mimir Task Definition
resource "aws_ecs_task_definition" "mimir" {
  family                   = "${var.project_name}-mimir"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.service_config.mimir.cpu
  memory                   = var.service_config.mimir.memory
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.mimir_task_role_arn

  container_definitions = jsonencode([
    {
      name      = "mimir"
      image     = "${var.ecr_repository_urls["lgtm-mimir"]}:${var.image_versions.mimir}"
      essential = true

      portMappings = [
        { containerPort = 8080, protocol = "tcp", name = "http" },
        { containerPort = 9095, protocol = "tcp", name = "grpc" },
        { containerPort = 7946, protocol = "tcp", name = "memberlist" }
      ]

      environment = [
        { name = "AWS_REGION", value = var.aws_region },
        { name = "MIMIR_S3_BUCKET", value = var.s3_bucket_name }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = var.log_group_names["mimir"]
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

  tags = merge(var.tags, {
    Name        = "${var.project_name}-mimir"
    Environment = var.environment
  })
}

# Loki Task Definition
resource "aws_ecs_task_definition" "loki" {
  family                   = "${var.project_name}-loki"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.service_config.loki.cpu
  memory                   = var.service_config.loki.memory
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.loki_task_role_arn

  container_definitions = jsonencode([
    {
      name      = "loki"
      image     = "${var.ecr_repository_urls["lgtm-loki"]}:${var.image_versions.loki}"
      essential = true

      portMappings = [
        { containerPort = 3100, protocol = "tcp", name = "http" },
        { containerPort = 7946, protocol = "tcp", name = "memberlist" }
      ]

      environment = [
        { name = "AWS_REGION", value = var.aws_region },
        { name = "LOKI_S3_BUCKET", value = var.s3_bucket_name }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = var.log_group_names["loki"]
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

  tags = merge(var.tags, {
    Name        = "${var.project_name}-loki"
    Environment = var.environment
  })
}

# Tempo Task Definition
resource "aws_ecs_task_definition" "tempo" {
  family                   = "${var.project_name}-tempo"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.service_config.tempo.cpu
  memory                   = var.service_config.tempo.memory
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.tempo_task_role_arn

  container_definitions = jsonencode([
    {
      name      = "tempo"
      image     = "${var.ecr_repository_urls["lgtm-tempo"]}:${var.image_versions.tempo}"
      essential = true

      portMappings = [
        { containerPort = 3200, protocol = "tcp", name = "http" },
        { containerPort = 4317, protocol = "tcp", name = "otlp-grpc" },
        { containerPort = 4318, protocol = "tcp", name = "otlp-http" }
      ]

      environment = [
        { name = "AWS_REGION", value = var.aws_region },
        { name = "TEMPO_S3_BUCKET", value = var.s3_bucket_name }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = var.log_group_names["tempo"]
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

  tags = merge(var.tags, {
    Name        = "${var.project_name}-tempo"
    Environment = var.environment
  })
}

# Pyroscope Task Definition
resource "aws_ecs_task_definition" "pyroscope" {
  family                   = "${var.project_name}-pyroscope"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.service_config.pyroscope.cpu
  memory                   = var.service_config.pyroscope.memory
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.pyroscope_task_role_arn

  container_definitions = jsonencode([
    {
      name      = "pyroscope"
      image     = "${var.ecr_repository_urls["lgtm-pyroscope"]}:${var.image_versions.pyroscope}"
      essential = true

      portMappings = [
        { containerPort = 4040, protocol = "tcp", name = "http" },
        { containerPort = 4041, protocol = "tcp", name = "grpc" }
      ]

      environment = [
        { name = "AWS_REGION", value = var.aws_region },
        { name = "PYROSCOPE_S3_BUCKET", value = var.s3_bucket_name },
        { name = "TZ", value = "Asia/Seoul" }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = var.log_group_names["pyroscope"]
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

  tags = merge(var.tags, {
    Name        = "${var.project_name}-pyroscope"
    Environment = var.environment
  })
}

# Grafana Task Definition
resource "aws_ecs_task_definition" "grafana" {
  family                   = "${var.project_name}-grafana"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.service_config.grafana.cpu
  memory                   = var.service_config.grafana.memory
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.grafana_task_role_arn

  container_definitions = jsonencode([
    {
      name      = "grafana"
      image     = "${var.ecr_repository_urls["lgtm-grafana"]}:${var.image_versions.grafana}"
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
          "awslogs-group"         = var.log_group_names["grafana"]
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

  tags = merge(var.tags, {
    Name        = "${var.project_name}-grafana"
    Environment = var.environment
  })
}

# Alloy Task Definition
resource "aws_ecs_task_definition" "alloy" {
  family                   = "${var.project_name}-alloy"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.service_config.alloy.cpu
  memory                   = var.service_config.alloy.memory
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.alloy_task_role_arn

  container_definitions = jsonencode([
    {
      name      = "alloy"
      image     = "${var.ecr_repository_urls["lgtm-alloy"]}:${var.image_versions.alloy}"
      essential = true

      portMappings = [
        { containerPort = 12345, protocol = "tcp", name = "http" },
        { containerPort = 9080, protocol = "tcp", name = "metrics" }
      ]

      environment = [
        { name = "LOKI_URL", value = "http://loki.${var.cloudmap_namespace_name}:3100/loki/api/v1/push" },
        { name = "LOKI_TENANT", value = var.alloy_config.loki_tenant },
        { name = "MIMIR_URL", value = "http://mimir.${var.cloudmap_namespace_name}:8080/api/v1/push" },
        { name = "MIMIR_TENANT", value = var.alloy_config.mimir_tenant }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = var.log_group_names["alloy"]
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

  tags = merge(var.tags, {
    Name        = "${var.project_name}-alloy"
    Environment = var.environment
  })
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
    container_port   = var.service_config.mimir.container_port
  }

  service_registries {
    registry_arn = var.cloudmap_service_arns["mimir"]
  }

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  deployment_controller {
    type = "ECS"
  }

  tags = merge(var.tags, {
    Name        = "mimir"
    Environment = var.environment
  })

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
    container_port   = var.service_config.loki.container_port
  }

  service_registries {
    registry_arn = var.cloudmap_service_arns["loki"]
  }

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  deployment_controller {
    type = "ECS"
  }

  tags = merge(var.tags, {
    Name        = "loki"
    Environment = var.environment
  })

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
    container_port   = var.service_config.tempo.container_port
  }

  service_registries {
    registry_arn = var.cloudmap_service_arns["tempo"]
  }

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  deployment_controller {
    type = "ECS"
  }

  tags = merge(var.tags, {
    Name        = "tempo"
    Environment = var.environment
  })

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

  load_balancer {
    target_group_arn = var.pyroscope_target_group_arn
    container_name   = "pyroscope"
    container_port   = var.service_config.pyroscope.container_port
  }

  service_registries {
    registry_arn = var.cloudmap_service_arns["pyroscope"]
  }

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  deployment_controller {
    type = "ECS"
  }

  tags = merge(var.tags, {
    Name        = "pyroscope"
    Environment = var.environment
  })

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
    container_port   = var.service_config.grafana.container_port
  }

  service_registries {
    registry_arn = var.cloudmap_service_arns["grafana"]
  }

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  deployment_controller {
    type = "ECS"
  }

  tags = merge(var.tags, {
    Name        = "grafana"
    Environment = var.environment
  })

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

  service_registries {
    registry_arn = var.cloudmap_service_arns["alloy"]
  }

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  deployment_controller {
    type = "ECS"
  }

  tags = merge(var.tags, {
    Name        = "alloy"
    Environment = var.environment
  })

  lifecycle {
    ignore_changes = [desired_count]
  }
}

# =============================================================================
# Service Discovery (CloudMap Integration)
# =============================================================================
# CloudMap 서비스는 cloudmap 모듈에서 생성됨
# ECS 서비스는 var.cloudmap_service_arns를 통해 연결
