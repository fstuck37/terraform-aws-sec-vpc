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

/* Routes for NGW Layer */
resource "aws_route" "ngw-default-route" {
  for_each = {for sd in local.subnet_data:sd.name=>sd
           if sd.layer == "ngw" }
  route_table_id         = aws_route_table.routers[each.value.name].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.inet-gw.id
}

/* Routes for TGW Layer */
resource "aws_route" "txgw-routes" {
  for_each = {for rt in local.tgw_routes:rt.index=>rt}
  route_table_id         = aws_route_table.routers[each.value.name].id
  destination_cidr_block = each.value.route
  transit_gateway_id     = var.transit_gateway_id
}


resource "aws_route" "txgw-routes-ep" {
  for_each = {for sd in local.subnet_data:sd.name=>sd
           if sd.layer == "tgw" }
  route_table_id         = aws_route_table.routers[each.value.name].id
  destination_cidr_block = "0.0.0.0/0"
  vpc_endpoint_id        = var.aws_vpc_endpoint_id
}


/* Routes for GWE Layer */
resource "aws_route" "txgwegw-routes" {
  for_each = {for sd in local.subnet_data:sd.name=>sd
           if sd.layer == "gwe" }
  route_table_id         = aws_route_table.routers[each.value.name].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.natgw[replace(each.value.name,"gwe","ngw")].id
}

/* Routes for MGT Layer */
/* mgt - 0.0.0.00 to igw-0c4351df562d0689c ?????? */

/* Routes for FWT Layer */
/* ???????????? */
