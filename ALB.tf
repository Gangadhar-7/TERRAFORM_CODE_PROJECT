# Application load balancer
resource "aws_lb" "app-lb" {
  name               = "${var.aws_profile}-app-load-balancer"
  internal           = false
  load_balancer_type = "application"
  subnets            = [for s in aws_subnet.public-subnet : s.id]
  security_groups    = [aws_security_group.app-lb-sg.id]

  tags = {
    Name = "${var.aws_profile}-app-load-balancer"
  }
}


# Target group
resource "aws_lb_target_group" "webapp_tg" {
  name        = "webapp-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.dev-vpc.id
  target_type = "instance"
  health_check {
    enabled             = true
    interval            = 60
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 2
    healthy_threshold   = 2
    unhealthy_threshold = 5
  }
}
