resource "aws_ec2_transit_gateway_vpc_attachment" "txgw_attachment" {
  count                   = var.transit_gateway_id == false ? 0 : 1
  subnet_ids              = local.subnet_ids["tgw"]
  transit_gateway_id      = var.transit_gateway_id
  vpc_id                  = aws_vpc.main_vpc.id
  appliance_mode_support  = var.appliance_mode_support 
  depends_on              = [aws_subnet.subnets]
}
