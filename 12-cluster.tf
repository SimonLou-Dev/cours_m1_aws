resource "aws_launch_template" "nginx_lt" {
  name_prefix   = "nginx-lt-"
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = "t3.micro"
  key_name      = aws_key_pair.deployer.key_name

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [aws_security_group.web_sg.id]
  }

  user_data = base64encode(<<-EOF
    #!/bin/bash
    dnf install -y nginx
    systemctl enable --now nginx
  EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "nginx-node"
    }
  }
}

resource "aws_autoscaling_group" "nginx_asg" {
  name_prefix         = "nginx-cluster-"
  desired_capacity    = 2
  min_size            = 2
  max_size            = 5
  vpc_zone_identifier = aws_subnet.private_subnet[*].id

  launch_template {
    id      = aws_launch_template.nginx_lt.id
    version = "$Latest"
  }

  health_check_type         = "ELB"
  health_check_grace_period = 90

  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}
