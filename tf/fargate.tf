resource "aws_ecs_cluster" "dotcom_fargate" {
  name = "tf-ecs-cluster"
}

resource "aws_ecs_task_definition" "dotcom_fargate" {
  family                   = "dotcom_fargate"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.fargate_cpu
  memory                   = var.fargate_memory

  container_definitions = <<DEFINITION
[
  {
    "cpu": ${var.fargate_cpu},
    "image": "${var.container_image}:${file("${path.module}/../version.txt")}",
    "memory": ${var.fargate_memory},
    "name": "dotcom_fargate",
    "networkMode": "awsvpc",
    "portMappings": [
      {
        "containerPort": ${var.app_port},
        "hostPort": ${var.app_port}
      }
    ]
  }
]
DEFINITION

}

resource "aws_ecs_service" "dotcom_fargate" {
  name            = "tf-ecs-service"
  cluster         = aws_ecs_cluster.dotcom_fargate.id
  task_definition = aws_ecs_task_definition.dotcom_fargate.arn
  desired_count   = var.desired_tasks
  launch_type     = "FARGATE"

  network_configuration {
    security_groups = [aws_security_group.ecs_tasks.id]
    subnets         = aws_subnet.private.*.id
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.dotcom_fargate.id
    container_name   = "dotcom_fargate"
    container_port   = var.app_port
  }

  depends_on = [
    aws_lb_listener.front_end80,
    aws_lb_listener.front_end443,
  ]
}

