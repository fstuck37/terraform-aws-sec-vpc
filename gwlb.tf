resource "aws_lb" "gwlb" {
  name                             = format("%s", var.vpc-name == true ? "${var.name-vars["account"]}-${replace(var.region,"-", "")}-${var.name-vars["name"]}" : var.vpc-name)
  load_balancer_type               = "gateway"
  subnets                          = local.subnet_ids["fwt"]
  enable_deletion_protection       = false
  enable_cross_zone_load_balancing = true

  tags = merge(
    var.tags,
    map("Name",format("%s", var.vpc-name == true ? "${var.name-vars["account"]}-${replace(var.region,"-", "")}-${var.name-vars["name"]}" : var.vpc-name)),
    local.resource-tags["aws_lb"]
  )
}

resource "aws_lb_target_group" "gwlbtg" {
  name        = format("%s", var.vpc-name == true ? "${var.name-vars["account"]}-${replace(var.region,"-", "")}-${var.name-vars["name"]}" : var.vpc-name)
  vpc_id      = aws_vpc.main_vpc.id
  protocol    = "GENEVE"
  port        = 6081
  target_type = "instance"

  health_check {
    enabled  = true
    port     = 80
    protocol = "TCP"
  }
}

resource "aws_lb_listener" "gwlb_listener" {
  load_balancer_arn = aws_lb.gwlb.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.gwlbtg.arn
  }
}


resource "aws_autoscaling_attachment" "gwlb-fw" {
  autoscaling_group_name = aws_autoscaling_group.firewall_asg.name
  alb_target_group_arn   = aws_elb.gwlb.id
}

