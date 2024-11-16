resource "aws_ecs_cluster" "ecs_cluster" {
  name = "ecs-cluster-${replace(var.environment, "_", "-")}"
}

resource "aws_ecs_cluster_capacity_providers" "ecs_capacity_provider" {
  cluster_name = aws_ecs_cluster.ecs_cluster.name
  capacity_providers = ["FARGATE"]
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name = "${aws_ecs_cluster.ecs_cluster.name}-task-execution-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "task_role_policy_attachment" {
  role = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_ecs_task_definition" "ecs_task_definition" {
  family = "ecs-task-${replace(var.environment, "_", "-")}"
  network_mode = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu = "256"
  memory = "512"
  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
  container_definitions = <<EOF
[
  {
    "name": "httpd",
    "image": "public.ecr.aws/docker/library/httpd:latest",
    "cpu": 256,
    "memory": 512,
    "essential": true,
    "portMappings": [
      {
        "containerPort": 80,
        "hostPort": 80,
        "protocol": "tcp"
      }
    ]
  }
]

EOF
}

resource "aws_lb" "ecs_lb" {
  name = "ecs-lb-${replace(var.environment, "_", "-")}"
  internal = false
  load_balancer_type = "application"
  security_groups = [aws_security_group.ecs_sg.id]
  subnets = [data.aws_subnet.public_1.id, data.aws_subnet.public_2.id, data.aws_subnet.public_3.id]
}

resource "aws_lb_target_group" "ecs_lb_target_group" {
  name = "ecs-tg-${replace(var.environment, "_", "-")}"
  port = 80
  protocol = "HTTP"
  target_type = "ip"
  vpc_id = data.aws_vpc.main.id
}

resource "aws_lb_listener" "ecs_lb_listener" {
  load_balancer_arn = aws_lb.ecs_lb.arn
  port = "80"
  protocol = "HTTP"

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.ecs_lb_target_group.arn
  }
}


resource "aws_ecs_service" "ecs_service" {
  name = "ecs-service-${replace(var.environment, "_", "-")}"
  cluster = aws_ecs_cluster.ecs_cluster.arn
  task_definition = aws_ecs_task_definition.ecs_task_definition.arn
  desired_count = 1
  launch_type = "FARGATE"
  network_configuration {
    subnets = [data.aws_subnet.public_1.id, data.aws_subnet.public_2.id, data.aws_subnet.public_3.id]
    security_groups = [aws_security_group.ecs_sg.id]
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.ecs_lb_target_group.arn
    container_name = "httpd"
    container_port = 80
  }
}

resource "aws_security_group" "ecs_sg" {
  name = "ecs-sg-${replace(var.environment, "_", "-")}"
  vpc_id = data.aws_vpc.main.id

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress { 
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
