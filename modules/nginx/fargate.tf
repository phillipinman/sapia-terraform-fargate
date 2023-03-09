resource "aws_ecs_cluster" "nginx" {
  name = "nginx"
}

resource "aws_ecs_cluster_capacity_providers" "nginx" {
  cluster_name = aws_ecs_cluster.nginx.name

  capacity_providers = ["FARGATE", "FARGATE_SPOT"]

  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = "FARGATE"
  }
}

resource "aws_ecs_task_definition" "nginx" {
  family                   = "nginx"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 2048
  memory                   = 4096
  execution_role_arn       = "arn:aws:iam::904199886538:role/aws-service-role/ecs.amazonaws.com/AWSServiceRoleForECS"
  container_definitions    = <<TASK_DEFINITION
[
  {
    "name": "nginx",
    "image": "nginx",
    "cpu": 1024,
    "memory": 2048,
    "essential": true,
    "portMappings" : [
      {
        "containerPort" : 80,
        "hostPort"      : 80
      }
    ],
    "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
            "awslogs-create-group": "true",
            "awslogs-group": "awslogs-nginx",
            "awslogs-region": "ap-southeast-2",
            "awslogs-stream-prefix": "awslogs-nginx"
        }
    }
  }
]
TASK_DEFINITION  

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }
}

resource "aws_ecs_service" "nginx" {
  name            = "nginx"
  cluster         = aws_ecs_cluster.nginx.id
  task_definition = aws_ecs_task_definition.nginx.arn
  desired_count   = 1
  network_configuration {
    subnets          = [aws_subnet.first.id, aws_subnet.second.id, aws_subnet.third.id]
    assign_public_ip = true
  }

  capacity_provider_strategy {
    capacity_provider = "FARGATE"
    base              = 1
    weight            = 50
  }

  capacity_provider_strategy {
    capacity_provider = "FARGATE_SPOT"
    base              = 0
    weight            = 50
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.nginx.arn
    container_name   = "nginx"
    container_port   = 80
  }
}