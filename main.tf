data "aws_ecs_cluster" "cluster" {
  cluster_name = var.cluster_name
}

resource "aws_ecs_task_definition" "datadog_agent" {
  family        = "datadog-agent"
  task_role_arn = aws_iam_role.datadog_agent.arn
  container_definitions = jsonencode([
    {
      "name" : "datadog-agent",
      "image" : "public.ecr.aws/datadog/agent:latest",
      "essential" : true,
      "environment" : [
        {
          "name" : "DD_API_KEY",
          "value" : "${var.datadog_api_key}"
        },
        {
          "name" : "ECS_FARGATE",
          "value" : "true"
        }
      ]
    }
  ])

  requires_compatibilities = ["FARGATE"]

  cpu          = 256
  memory       = 512
  network_mode = "awsvpc"

  depends_on = [aws_iam_role_policy.datadog_agent]
}

resource "aws_ecs_service" "datadog_agent" {
  name            = "datadog_agent"
  cluster         = data.aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.datadog_agent.arn
  desired_count   = 1

  network_configuration {
    subnets          = var.subnets
    security_groups  = var.security_groups
    assign_public_ip = false
  }
}

resource "aws_iam_role" "datadog_agent" {
  name = "CustomDatadogRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = "CustomDatadogRole"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy" "datadog_agent" {
  name = "CustomDatadogRolePolicy"
  role = aws_iam_role.datadog_agent.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ecs:ListClusters",
          "ecs:ListContainerInstances",
          "ecs:DescribeContainerInstances",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}