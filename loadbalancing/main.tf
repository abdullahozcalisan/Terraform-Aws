resource "aws_lb" "theo_lb" {
  name            = "theo-lb"
  security_groups = var.pub_sec_gr
  subnets         = var.pub_sub_id
  idle_timeout    = 400
}


resource "aws_lb_target_group" "theo_ltg" {
  name     = "theo-lb-tg-${substr(uuid(), 0, 3)}"
  port     = var.tg_port
  protocol = var.tg_protocol
  vpc_id   = var.vpc_id
  lifecycle {
    ignore_changes        = [name]
    create_before_destroy = true
  }
  health_check {
    healthy_threshold   = var.lb_healthy_threshold
    unhealthy_threshold = var.lb_unhealthy_threshold
    timeout             = var.lb_timeout
    interval            = var.lb_interval
  }
}

resource "aws_lb_listener" "theo_listener" {
  load_balancer_arn = aws_lb.theo_lb.arn
  port              = var.listener_port
  protocol          = var.listener_protocol
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.theo_ltg.arn
  }

}
