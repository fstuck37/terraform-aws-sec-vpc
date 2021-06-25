/* NOTE: Hard coded to ngw layer */
resource "aws_nat_gateway" "natgw" {
  for_each       = toset(data.aws_availability_zones.azs.names)
  allocation_id  = aws_eip.eip[each.value].id
  subnet_id      = aws_subnet.subnets[format("%02s", "${var.name-vars["account"]}-${var.name-vars["name"]}-ngw-az-${element(split("-", each.value), length(split("-", each.value )) - 1)}")].id
}