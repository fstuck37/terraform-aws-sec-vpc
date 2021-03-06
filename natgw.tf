/* NOTE: Hard coded to ngw layer */
resource "aws_nat_gateway" "natgw" {
  for_each = {for sd in local.subnet_data:sd.name=>sd
           if sd.layer == "ngw" }
  allocation_id  = aws_eip.eip[each.value.az].id
  subnet_id      = aws_subnet.subnets[each.value.name].id
  tags = {
    Name = each.value.name
  }
}
