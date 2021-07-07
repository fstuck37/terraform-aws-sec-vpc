resource "aws_vpc_endpoint_service" "gateway" {
  acceptance_required        = false
  gateway_load_balancer_arns = [aws_lb.gwlb.arn]

  tags                 = merge(
    var.tags,
    map("Name",format("%s", var.vpc-name == true ? "${var.name-vars["account"]}-${replace(var.region,"-", "")}-${var.name-vars["name"]}" : var.vpc-name))
  )
}

resource "aws_vpc_endpoint_service_allowed_principal" "gateway" {
  for_each = toset(var.endpoint_service_allowed_principal)
    vpc_endpoint_service_id = aws_vpc_endpoint_service.gateway.id
    principal_arn           = each.value
}