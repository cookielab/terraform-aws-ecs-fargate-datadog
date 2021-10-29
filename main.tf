data "aws_ecs_cluster" "cluster" {
  cluster_name = var.cluster_name
}

resource "aws_ecs_task_definition" "datadog_agent" {
  family = "datadog-agent"
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

  requires_compatibilities = "FARGATE"

  cpu          = 10
  memory       = 256
  network_mode = "awsvpc"
}

resource "aws_ecs_service" "datadog_agent" {
  name            = "datadog_agent"
  cluster         = data.aws_ecs_cluster.cluster.name
  task_definition = aws_ecs_task_definition.datadog_agent.arn
  desired_count   = 1
  iam_role        = aws_iam_role.datadog_agent.arn
  depends_on      = [aws_iam_role_policy.datadog_agent]

  network_configuration = {
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