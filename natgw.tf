/* NOTE: Hard coded to ngw layer */
resource "aws_nat_gateway" "natgw" {
  for_each = {for i in local.subnet_data:i.name=>i
           if contains(keys(i), "ngw")
  }
  allocation_id  = aws_eip.eip[each.value.az].id
  subnet_id      = aws_subnet.subnets[each.value.name].id
}
