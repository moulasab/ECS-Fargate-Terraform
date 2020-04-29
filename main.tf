provider "aws" {
  shared_credentials_file = "aws credentials path"
  region                  = "region"
  profile                 = "name"
}

#Create ECR repo 
resource "aws_ecr_repository" "mercury" {
  name                 = "dev-mercury-ecr"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = false
  }
}

#ALB creation
resource "aws_lb" "ecs-alb" {
  name               = "Dev-ECS-ALB"
  internal           = false
  load_balancer_type = "application"
  subnets            = ["${var.public-subnet-1a}", "${var.public-subnet-1b}"]
  security_groups    = ["${var.ecs-sg}", "${var.ping-sg}"]

  tags = {
    Environment = "Dev"
    Name        = "Dev-ECS-ALB"
  }
}

#Target Group
resource "aws_lb_target_group" "ecs-target-group" {
  name        = "ecs-target-group"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = "${var.VPC}"
  target_type = "ip"

  health_check {
    healthy_threshold   = "3"
    interval            = "30"
    protocol            = "HTTP"
    matcher             = "200"
    timeout             = "3"
    path                = "/healthcheck/"
    port                = 8000
    unhealthy_threshold = "2"
  }
}

# Redirect all traffic from the ALB to the target group
resource "aws_lb_listener" "dev-ecs-http" {
  load_balancer_arn = aws_lb.ecs-alb.id
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
    #target_group_arn = aws_lb_target_group.ecs-target-group.id
    #use target group arn for action type is forward
  }
}

resource "aws_lb_listener" "dev-ecs-https" {
  load_balancer_arn = aws_lb.ecs-alb.id
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = "acm certificate arn"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ecs-target-group.id
  }
}

#Create ECS Cluster, Service and Task definition
resource "aws_ecs_cluster" "main" {
  name = "webapp-cluster"
}

resource "aws_ecs_task_definition" "ecs_task_definition" {
  family                   = "mercury-service"
  network_mode             = "awsvpc"
  task_role_arn            = var.ecs_task_execution_role
  execution_role_arn       = var.ecs_task_execution_role
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.fargate_cpu
  memory                   = var.fargate_memory

  container_definitions = <<TASK_DEFINITION
    [
      {
        "cpu": ${var.fargate_cpu},
        "image": "${var.image-arn}",
        "memory": ${var.fargate_memory},
        "name": "mercury",
        "networkMode": "awsvpc",
         "environment": [
          {
            "name": "APP_KEY",
            "value": "Variables"
          },
          {
            "name": "${var.db-name-postgres}",
            "value": "${var.db-name}"
          },
          {
            "name": "${var.db-user-postgres}",
            "value": "${var.db-user}"
          },
          {
            "name": "${var.db-pwd-postgres}",
            "value": "${var.db-password}"
          },
          {
            "name": "${var.db-host-postgres}",
            "value": "${var.db-host}"
          },
          {  
            "name": "${var.db-port-postgres}",
            "value": "${var.db-port}"
          }
        ],
        "logConfiguration": {
          "logDriver": "awslogs",
          "options": {
            "awslogs-group" : "/ecs/mercury",
            "awslogs-region": "region",
            "awslogs-stream-prefix": "ecs"
          }
        },
        "portMappings": [
          {
          "containerPort": 8000,
          "protocol": "tcp",
          "hostPort": 8000
          }
        ]
      }
  ]
  TASK_DEFINITION
}

resource "aws_ecs_service" "main" {
  name            = "mercury-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.ecs_task_definition.arn
  desired_count   = 1
  depends_on      = [aws_lb.ecs-alb]
  launch_type     = "FARGATE"

  network_configuration {
    security_groups  = ["${var.ecs-sg}", "${var.ping-sg}", "${var.dev-alb-sg}"]
    subnets          = ["${var.private-subnet-1a}", "${var.private-subnet-1b}"]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.ecs-target-group.arn
    container_name   = "mercury"
    container_port   = 8000
  }
}