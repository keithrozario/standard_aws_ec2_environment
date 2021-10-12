resource "aws_lb" "rds_proxy" {
  name               = "rds-proxy"
  load_balancer_type = "network"

  subnet_mapping {
    subnet_id            = var.subnet_ids[0]
  }

  subnet_mapping {
    subnet_id            = var.subnet_ids[1]
  }
}

resource "aws_lb_listener" "proxy_incoming" {
  load_balancer_arn = aws_lb.rds_proxy.arn
  port              = "3306"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.proxy_outgoing.arn
  }
}

resource "aws_lb_target_group" "proxy_outgoing" {
  name        = "proxy-outgoing"
  port        = 3306
  protocol    = "TCP"
  target_type = "ip"
  vpc_id      = var.vpc_id
}