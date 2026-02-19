resource "aws_security_group" "alb" {
  name = "${var.project_name}-alb-sg"
  description = "ALB Secrurity Group"
  vpc_id = aws_vpc.main.id

  ingress {
    description = "HTTP from internet"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "All outbound"
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-alb-sg"
  }
}

resource "aws_security_group" "ecs" {
  name = "${var.project_name}-ecs-sg"
  description = "ECS Security Group"
  vpc_id = aws_vpc.main.id

  ingress {
    description = "HTTP from ALB"
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    description = "All outbound"
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-ecs-sg"
  }
}

resource "aws_security_group" "rds" {
  name = "${var.project_name}-rds-sg"
  description = "RDS Security Group"
  vpc_id = aws_vpc.main.id

  ingress {
    description = "PostgreSQL from ECS"
    from_port = 5432
    to_port = 5432
    protocol = "tcp"
    security_groups = [aws_security_group.ecs.id]
  }

  tags = {
    Name = "${var.project_name}-rds-sg"
  }
}