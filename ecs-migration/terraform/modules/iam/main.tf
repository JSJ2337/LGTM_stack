# =============================================================================
# IAM Module - Resources
# =============================================================================

# -----------------------------------------------------------------------------
# Assume Role Policy (ECS Tasks)
# -----------------------------------------------------------------------------

data "aws_iam_policy_document" "ecs_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

# -----------------------------------------------------------------------------
# Task Execution Role (ECR pull, CloudWatch Logs)
# -----------------------------------------------------------------------------

resource "aws_iam_role" "task_execution" {
  name               = "${var.project_name}-${var.environment}-task-execution-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_assume_role.json

  tags = merge(var.tags, {
    Name        = "${var.project_name}-${var.environment}-task-execution-role"
    Environment = var.environment
  })
}

resource "aws_iam_role_policy_attachment" "task_execution" {
  role       = aws_iam_role.task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy" "task_execution_secrets" {
  name = "secrets-access"
  role = aws_iam_role.task_execution.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue"
        ]
        Resource = "arn:aws:secretsmanager:*:*:secret:lgtm/*"
      }
    ]
  })
}

# -----------------------------------------------------------------------------
# LGTM Task Role (S3 Access - Mimir, Loki, Tempo, Pyroscope)
# -----------------------------------------------------------------------------

resource "aws_iam_role" "lgtm_task" {
  name               = "${var.project_name}-${var.environment}-task-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_assume_role.json

  tags = merge(var.tags, {
    Name        = "${var.project_name}-${var.environment}-task-role"
    Environment = var.environment
  })
}

resource "aws_iam_role_policy" "lgtm_s3_access" {
  name = "s3-access"
  role = aws_iam_role.lgtm_task.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::${var.s3_bucket_name}",
          "arn:aws:s3:::${var.s3_bucket_name}/*"
        ]
      }
    ]
  })
}

# -----------------------------------------------------------------------------
# Alloy Task Role (CloudWatch Access)
# -----------------------------------------------------------------------------

resource "aws_iam_role" "alloy_task" {
  name               = "${var.project_name}-${var.environment}-alloy-task-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_assume_role.json

  tags = merge(var.tags, {
    Name        = "${var.project_name}-${var.environment}-alloy-task-role"
    Environment = var.environment
  })
}

resource "aws_iam_role_policy" "alloy_cloudwatch_access" {
  name = "cloudwatch-access"
  role = aws_iam_role.alloy_task.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "cloudwatch:GetMetricData",
          "cloudwatch:GetMetricStatistics",
          "cloudwatch:ListMetrics",
          "logs:GetLogEvents",
          "logs:FilterLogEvents",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams",
          "tag:GetResources",
          "ec2:DescribeInstances",
          "ec2:DescribeRegions",
          "rds:DescribeDBInstances",
          "elasticloadbalancing:DescribeLoadBalancers",
          "elasticloadbalancing:DescribeTargetGroups"
        ]
        Resource = "*"
      }
    ]
  })
}

# -----------------------------------------------------------------------------
# Grafana Task Role
# -----------------------------------------------------------------------------

resource "aws_iam_role" "grafana_task" {
  name               = "${var.project_name}-${var.environment}-grafana-task-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_assume_role.json

  tags = merge(var.tags, {
    Name        = "${var.project_name}-${var.environment}-grafana-task-role"
    Environment = var.environment
  })
}
