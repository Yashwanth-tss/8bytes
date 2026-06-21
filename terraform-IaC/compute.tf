# ECR repository
resource "aws_ecr_repository" "app_ecr" {
  name = "${var.environment}-app-ecr"
}

resource "aws_ecr_repository" "api_ecr" {
  name = "${var.environment}-api-ecr"
}

# Create Key Pair to SSH into EC2 instances
resource "tls_private_key" "rsa_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "instance_key" {
  key_name   = var.key_name
  public_key = tls_private_key.rsa_key.public_key_openssh
}

resource "local_file" "private_key" {
  content  = tls_private_key.rsa_key.private_key_pem
  filename = "${path.module}/${var.key_name}.pem"
}

# Application Compute instance
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "app_server" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.small"
  subnet_id              = aws_subnet.public_az_1.id
  vpc_security_group_ids = [aws_security_group.app_sg.id]
  key_name               = aws_key_pair.instance_key.key_name
  user_data              = <<-EOF
              #!/bin/bash
              sudo apt update -y
              sudo apt install -y docker.io
              sudo systemctl start docker
              sudo systemctl enable docker
              sudo usermod -aG docker ubuntu
              sudo apt install postgresql-client
              EOF
  tags = {
    Name = "${var.environment}-app-instance"
  }
}

# ALB configuration
resource "aws_lb" "app_alb" {
  name            = "${var.environment}-app-alb"
  subnets         = [aws_subnet.public_az_1.id, aws_subnet.public_az_2.id]
  security_groups = [aws_security_group.alb_sg.id]
  tags = {
    Name = "${var.environment}-app-alb"
  }
}

resource "aws_lb_target_group" "app_tg" {
  name     = "${var.environment}-app-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
  tags = {
    Name = "${var.environment}-app-tg"
  }

  health_check {
    path                = "/health"
    port                = 80
    healthy_threshold   = 2
    unhealthy_threshold = 5
  }
}

resource "aws_lb_listener" "app_listener" {
  load_balancer_arn = aws_lb.app_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}

resource "aws_lb_target_group_attachment" "app_tg_attachment" {
  target_group_arn = aws_lb_target_group.app_tg.arn
  target_id        = aws_instance.app_server.id
  port             = 80
}