resource "aws_lb" "nginx_lb" {
  name               = "nginx-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb_sg.id]
  subnets            = aws_subnet.public_subnet[*].id

  depends_on = [ aws_security_group.lb_sg, aws_subnet.public_subnet ]
}

resource "aws_lb_target_group" "nginx_tg" {
  name     = "nginx-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.kevin_vpc.id

  health_check {
    path                = "/"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    interval            = 10
  }

  depends_on = [ aws_vpc.kevin_vpc ]
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.nginx_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nginx_tg.arn
  }

  depends_on = [ 
    aws_lb.nginx_lb,
    aws_lb_target_group.nginx_tg
   ]
}

resource "aws_autoscaling_attachment" "nginx_asg_attachment" {
  autoscaling_group_name = aws_autoscaling_group.nginx_asg.id
  lb_target_group_arn    = aws_lb_target_group.nginx_tg.arn

  depends_on = [ aws_autoscaling_group.nginx_asg, aws_lb_target_group.nginx_tg ]
}

output "lb_dns" {
  value = "http://${aws_lb.nginx_lb.dns_name}"
}
