resource "aws_sns_topic" "unhealthy_host" {
  name = "unhealthy_host"
}


# resource "aws_lb_target_group" "instance_target" {
#   name     = "instance-target"
#   port     = 80
#   protocol = "HTTP"
#   vpc_id   = module.vpc.vpc_id

#   health_check {
#     enabled = true
#     healthy_threshold   = 2
#     interval            = 30
#     protocol            = "HTTP"
#     unhealthy_threshold = 3
#     matcher = "200,202"
#     path = "/index.html"
#     port = 80
#     timeout = 2
#   }
# }

# resource "aws_lb_target_group_attachment" "instance_attach" {
#   target_group_arn = aws_lb_target_group.instance_target.arn
#   target_id        = module.linux_ec2.instance_ids[0]
#   port             = 80
# }

# resource "aws_lb_listener" "front_end" {
#   load_balancer_arn = module.alb.lb_arn
#   port              = "80"
#   protocol          = "HTTP"

#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.instance_target.arn
#   }
# }


# resource "aws_cloudwatch_metric_alarm" "alb_unhealthy_host" {
#   alarm_name          = "UnHealthyHost"
#   comparison_operator = "GreaterThanThreshold"
#   threshold           = 0
#   evaluation_periods  = 2
#   metric_name         = "UnHealthyHostCount"
#   namespace           = "AWS/ApplicationELB"
#   period              = 60
#   statistic           = "Minimum"
#   alarm_description   = "Number of unhealthy nodes in Target Group"
#   actions_enabled     = "true"
#   alarm_actions       = [aws_sns_topic.unhealthy_host.arn]
#   ok_actions          = [aws_sns_topic.unhealthy_host.arn]
#   dimensions = {
#     TargetGroup  = aws_lb_target_group.instance_target.arn_suffix
#     LoadBalancer = module.alb.lb_arn_suffix
#     }
# }