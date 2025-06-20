provider "aws" {
  region = var.aws_region
}

data "terraform_remote_state" "alb" {
  backend = "s3"
  config = {
    bucket = "terraform-states-816069165502"
    key    = "terraform-alb/terraform.tfstate"
    region = "us-east-1"
  }
}

resource "aws_ecs_cluster" "this" {
  name = "microservices-cluster"
}

# Security Group do ECS que permite entrada apenas do ALB
resource "aws_security_group" "cliente_service_ecs_sg" {
  name        = "cliente-service-ecs-sg"
  description = "Permite acesso HTTP vindo do ALB"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 4000
    to_port         = 4000
    protocol        = "tcp"
    security_groups = [data.terraform_remote_state.alb.outputs.alb_security_group_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_ecs_task_definition" "this" {
  family                   = "cliente-service-task-${replace(timestamp(), ":", "-")}"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.task_role_arn

container_definitions = jsonencode([
  {
    name  = "cliente-service"
    image = var.ecr_image_url
    portMappings = [
      {
        containerPort = 4000
      }
    ],
    environment = [
      { name = "PORT", value = "4000" },
      { name = "DB_HOST", value = var.db_host },
      { name = "DB_PORT", value = tostring(var.db_port) },
      { name = "DB_USER", value = var.db_user },
      { name = "DB_PASSWORD", value = var.db_password },
      { name = "DB_NAME", value = var.db_name },
      { name = "COGNITO_USER_POOL_ID", value = var.cognito_user_pool_id },
      { name = "COGNITO_CLIENT_ID", value = var.cognito_client_id },
      { name = "API_BASE_URL", value = var.api_base_url },
      { name = "NODE_ENV", value = var.node_env }
    ],
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = "/ecs/cliente-service"
        awslogs-region        = var.aws_region
        awslogs-stream-prefix = "ecs"
      }
    }
  }
])

}
resource "aws_cloudwatch_log_group" "cliente_service" {
  name              = "/ecs/cliente-service"
  retention_in_days = 7
}


resource "aws_ecs_service" "this" {
  name            = "cliente-service"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.this.arn
  launch_type     = "FARGATE"
  desired_count   = 1

  network_configuration {
    subnets          = var.subnet_ids
    security_groups  = [aws_security_group.cliente_service_ecs_sg.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = data.terraform_remote_state.alb.outputs.cliente_service_target_group_arn
    container_name   = "cliente-service"
    container_port   = 4000
  }

  depends_on = [aws_ecs_task_definition.this]
}
