resource "aws_route_table" "routers" {
  for_each = {for i in local.subnet_data:i.name=>i}
  vpc_id   = aws_vpc.main_vpc.id
  tags     = merge(
            var.tags,
            map("Name", each.value.name ),
            local.resource-tags["aws_route_table"]
           )
}

resource "aws_route_table_association" "associations" {
  for_each = {for i in local.subnet_data:i.name=>i}
  subnet_id      = aws_subnet.subnets[each.key].id
  route_table_id = aws_route_table.routers[each.key].id
}


resource "aws_route" "ngw-default-route" {
  for_each = {for sd in local.subnet_data:sd.name=>sd
           if sd.layer == "ngw" }
  route_table_id         = aws_route_table.routers[each.value.name].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.inet-gw.id
}
