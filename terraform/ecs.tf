# 클러스터 (컨테이너 실행)
resource "aws_ecs_cluster" "main" {
  name = "${var.project_name}-cluster"

  tags = {
    Name = "${var.project_name}-cluster"
  }
}

# 로그 그룹
resource "aws_cloudwatch_log_group" "ecs" {
  name = "/ecs/${var.project_name}"
  retention_in_days = 7

  tags = {
    Name = "${var.project_name}-logs"
  }
}

# esc 태스크 실행 역할 IAM
resource "aws_iam_role" "ecs_execution" {
  name = "${var.project_name}-ecs-execution"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
            Service = "ecs-tasks.amazonaws.com"
        }
    }]
  })

  tags = {
    Name = "${var.project_name}-ecs-execution"
  }
}

resource "aws_iam_role_policy_attachment" "ecs_execution" {
  role = aws_iam_role.ecs_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# ecs 태스크 정의
resource "aws_ecs_task_definition" "main" {
  family = "${var.project_name}-task"
  network_mode = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu = "256"
  memory = "512"
  execution_role_arn = aws_iam_role.ecs_execution.arn

  container_definitions = jsonencode([{
    name = "${var.project_name}-server"
    image = "${aws_ecr_repository.main.repository_url}:latest"

    portMappings = [{
        containerPort = 8080
        protocol = "tcp"
    }]

    environment = [{
        name = "DATABASE_URL"
        value = "host=${aws_db_instance.main.address} user=${var.db_username} password=${var.db_password} dbname=mycard port=5432 sslmode=require"
    }]

    logConfiguration = {
        logDriver = "awslogs"
        options = {
            "awslogs-group" = aws_cloudwatch_log_group.ecs.name
            "awslogs-region" = var.aws_region
            "awslogs-stream-prefix" = "ecs"
        }
    }
  }])

  tags = {
    Name = "${var.project_name}-task"
  }
}

# ecs 서비스
resource "aws_ecs_service" "main" {
  name = "${var.project_name}-service"
  cluster = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.main.arn
  desired_count = 1
  launch_type = "FARGATE"

  network_configuration {
    subnets = [aws_subnet.public_a.id, aws_subnet.public_c.id]
    security_groups = [aws_security_group.ecs.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.main.arn
    container_name = "${var.project_name}-server"
    container_port = 8080
  }

  depends_on = [ aws_lb_listener.http ]

  tags = {
    Name = "${var.project_name}-service"
  }
}