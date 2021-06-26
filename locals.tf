data "aws_availability_zones" "azs" {
  state = "available"
}

locals {
  emptymaps = [{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{}]
  resource_list = ["aws_vpc", "aws_vpn_gateway", "aws_subnet", "aws_network_acl", "aws_internet_gateway", "aws_egress_only_internet_gateway", "aws_cloudwatch_log_group", "aws_vpc_dhcp_options", "aws_route_table", "aws_route53_resolver_endpoint"]
  empty-resource-tags = zipmap(local.resource_list, slice(local.emptymaps, 0 ,length(local.resource_list)))
  resource-tags = merge(local.empty-resource-tags, var.resource-tags)

  subnet_data = flatten([
    for i, sn in var.subnets : [
      for ii, az in data.aws_availability_zones.azs.names : {
        az           = az
        layer        = sn
        name         = format("%02s", "${var.name-vars["account"]}-${var.name-vars["name"]}-${sn}-az-${element(split("-", az), length(split("-", az )) - 1)}")
        index        = "${(i*length(data.aws_availability_zones.azs.names))+ii}"
        layer_index  = i
        subnet_index = ii
        layer_cidr = cidrsubnet(var.vpc-cidrs[0], ceil(log(length(data.aws_availability_zones.azs.names)+ var.az_growth,2)), i )
        subnet_cidr = cidrsubnet(cidrsubnet(var.vpc-cidrs[0], ceil(log(length(data.aws_availability_zones.azs.names)+ var.az_growth,2)), i ) , (var.subnet_size - (element(split("/", var.vpc-cidrs[0]),1) + ceil(log(length(data.aws_availability_zones.azs.names)+ var.az_growth,2)))) , ii )
       }]
    ])

  subnet_ids = {
    for layer in var.subnets:
    layer => [
      for sd in local.subnet_data: 
        aws_subnet.subnets[sd.name].id
    if sd.layer == layer ]
  }

  subnet_cidrs = {
    for layer in var.subnets:
    layer => [
      for sd in local.subnet_data: 
        aws_subnet.subnets[sd.name].cidr_block
    if sd.layer == layer ]
  }

  routetable_ids = {
    for layer in var.subnets:
    layer => [
      for sd in local.subnet_data: 
        aws_route_table.routers[sd.name].id
    if sd.layer == layer ]
  }





/* may need to review or modify */
/*
  txgw_routes = flatten([
  for rt in var.transit_gateway_routes : [
    for rtid in aws_route_table.privrt : {
      name        = "${rtid.id}-${rt}"
      route       = rt
      route_table = rtid.id
      }
    if var.transit_gateway_id != false]
  ])
 
 
 route53-zones = split(",", join(",", data.template_file.subnet-24s-lists.*.rendered))
*/
}

