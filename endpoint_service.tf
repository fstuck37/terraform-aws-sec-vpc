resource "aws_vpc_endpoint_service" "gateway" {
  acceptance_required        = false
  gateway_load_balancer_arns = [aws_lb.gwlb.arn]
  allowed_principals         = var.endpoint_service_allowed_principal

  tags = merge(
    var.tags,
    map("Name",format("%s", var.vpc-name == true ? "${var.name-vars["account"]}-${replace(var.region,"-", "")}-${var.name-vars["name"]}" : var.vpc-name))
  )
}

resource "aws_vpc_endpoint" "gateway-ep" {
  for_each = {for sd in local.subnet_data:sd.name=>sd
      if sd.layer == "gwe" }

  vpc_id            = aws_vpc.main_vpc.id
  service_name      = aws_vpc_endpoint_service.gateway.service_name
  vpc_endpoint_type = "GatewayLoadBalancer"

  subnet_ids        = [aws_subnet.subnets[each.value.name].id]

  tags = merge(
    var.tags,
    map("Name",format("%s", var.vpc-name == true ? "${var.name-vars["account"]}-${replace(var.region,"-", "")}-${var.name-vars["name"]}" : var.vpc-name))
  )
}