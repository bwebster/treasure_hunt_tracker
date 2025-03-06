provider "aws" {
  region = "us-east-1"
}

# Create ECR Repository
resource "aws_ecr_repository" "treasure_hunt_tracker" {
  name = "bwebster/treasure_hunt_tracker"
}

# IAM Role for App Runner
resource "aws_iam_role" "app_runner_role" {
  name = "apprunner_execution_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "build.apprunner.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      },
      {
        Effect = "Allow",
        Principal = {
          Service = "apprunner.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# IAM Policy for App Runner to access ECR
resource "aws_iam_role_policy_attachment" "app_runner_ecr_policy" {
  role       = aws_iam_role.app_runner_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

# AWS App Runner Service
resource "aws_apprunner_service" "treasure_hunt_tracker" {
  service_name = "treasure_hunt_tracker"

  source_configuration {
    image_repository {
      image_identifier      = "${aws_ecr_repository.treasure_hunt_tracker.repository_url}:latest"
      image_repository_type = "ECR"
    }

    auto_deployments_enabled = true
  }

  instance_configuration {
    cpu    = "512"
    memory = "1024"
  }

  health_check_configuration {
    path                = "/"
    protocol            = "HTTP"
    interval            = 10
    timeout             = 5
    healthy_threshold   = 1
    unhealthy_threshold = 3
  }

  tags = {
    Name = "treasure-hunt-tracker"
  }
}
