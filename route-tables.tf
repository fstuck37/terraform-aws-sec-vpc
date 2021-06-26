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
  for_each               = {for i in local.routetable_ids["ngw"]:i=>i}
  route_table_id         = each.value
  destination_cidr_block = "0.0.0.0/0"
  gateway_id         = resource aws_egress_only_internet_gateway.eg-inet-gw.id
}


/*
resource "aws_route" "privrt-gateway" {
  count                  = !contains(keys(var.subnets), "pub")  || !var.deploy_natgateways || var.dx_bgp_default_route ? 0 : local.num-availbility-zones
  route_table_id         = aws_route_table.privrt.*.id[count.index]
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.natgw.*.id[count.index]
}

aws_egress_only_internet_gateway.eg-inet-gw.id


*/
