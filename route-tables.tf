/* Internal Routes */
resource "aws_ec2_managed_prefix_list" "internal_networks" {
  name           = "Internal Networks"
  address_family = "IPv4"
  max_entries    = length(var.internal_networks)

  dynamic "entry" {
    for_each    = toset(var.internal_networks)
    content {
      cidr = entry.value
    }
  }
}

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

resource "aws_route" "ngw-internal-route" {
  for_each = {for rt in local.tgw_routes:rt.index=>rt}
  route_table_id         = aws_route_table.routers[replace(each.value.name,"tgw","ngw")].id
  destination_cidr_block = each.value.route
  vpc_endpoint_id        = aws_vpc_endpoint.gateway-ep[replace(each.value.name,"tgw","gwe")].id
}

resource "aws_route" "txgw-routes-ep" {
  for_each = {for sd in local.subnet_data:sd.name=>sd
           if sd.layer == "tgw" }
  route_table_id         = aws_route_table.routers[each.value.name].id
  destination_cidr_block = "0.0.0.0/0"
  vpc_endpoint_id        = aws_vpc_endpoint.gateway-ep[replace(each.value.name,"tgw","gwe")].id
}

/* Routes for GWE Layer */
resource "aws_route" "gwe-default-route" {
  for_each = {for sd in local.subnet_data:sd.name=>sd
           if sd.layer == "gwe" }
  route_table_id         = aws_route_table.routers[each.value.name].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.natgw[replace(each.value.name,"gwe","ngw")].id
}

resource "aws_route" "gwe-internal-routes" {
  for_each = {for sd in local.subnet_data:sd.name=>sd
           if sd.layer == "gwe" }
  route_table_id              = aws_route_table.routers[each.value.name].id
  destination_prefix_list_id  = aws_ec2_managed_prefix_list.internal_networks.id
  transit_gateway_id          = var.transit_gateway_id
}

/* Routes for MGT Layer */
/*  Commented out until Autoscaling can handle multiple eni's in multiple subnets

resource "aws_route" "mgt-routes" {
  for_each = {for sd in local.subnet_data:sd.name=>sd
           if sd.layer == "mgt" }
  route_table_id         = aws_route_table.routers[each.value.name].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.natgw[replace(each.value.name,"mgt","ngw")].id
}

resource "aws_route" "mgt-internal-routes" {
  for_each = {for sd in local.subnet_data:sd.name=>sd
           if sd.layer == "mgt" }
  route_table_id              = aws_route_table.routers[each.value.name].id
  destination_prefix_list_id  = aws_ec2_managed_prefix_list.internal_networks.id
  transit_gateway_id          = var.transit_gateway_id
}
*/

/* Routes for FWT Layer */
resource "aws_route" "fwt-default-route" {
  for_each = {for sd in local.subnet_data:sd.name=>sd
           if sd.layer == "fwt" }
  route_table_id         = aws_route_table.routers[each.value.name].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.natgw[replace(each.value.name,"fwt","ngw")].id
}

resource "aws_route" "fwt-internal-routes" {
  for_each = {for sd in local.subnet_data:sd.name=>sd
           if sd.layer == "fwt" }
  route_table_id              = aws_route_table.routers[each.value.name].id
  destination_prefix_list_id  = aws_ec2_managed_prefix_list.internal_networks.id
  transit_gateway_id          = var.transit_gateway_id
}