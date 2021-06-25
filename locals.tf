data "aws_availability_zones" "azs" {
  state = "available"
}

locals {
  emptymaps = [{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{}]
  resource_list = ["aws_vpc", "aws_vpn_gateway", "aws_subnet", "aws_network_acl", "aws_internet_gateway", "aws_egress_only_internet_gateway", "aws_cloudwatch_log_group", "aws_vpc_dhcp_options", "aws_route_table", "aws_route53_resolver_endpoint"]
  empty-resource-tags = zipmap(local.resource_list, slice(local.emptymaps, 0 ,length(local.resource_list)))
  resource-tags = merge(local.empty-resource-tags, var.resource-tags)

  subnet_data = flatten([
  for i, az in data.aws_availability_zones.azs.names : [
    for ii, sn in var.subnets : {
      az      = az
      sn      = sn
      name    = format("%02s", "${var.name-vars["account"]}-${var.name-vars["name"]}-${sn}-az-${element(split("-", az), length(split("-", az )) - 1)}")
      index   = "${(i*length(var.subnets))+ii}"
      subnet  = cidrsubnet( var.vpc-cidrs[0] , (var.subnet_size - element(split("/", var.vpc-cidrs[0]),1)) , (( i * length(var.subnets)) + ii) )
    }]
  ])

  subnet_ids = {
    for layer in var.subnets:
    layer => [
      for sd in local.subnet_data: 
        aws_subnet.subnets[sd.name].id
    if replace( sd.name , layer, "") != sd.name ]
  }

  subnet_cidrs = {
    for layer in var.subnets:
    layer => [
      for sd in local.subnet_data: 
        aws_subnet.subnets[sd.name].cidr_block
    if replace( sd.name , layer, "") != sd.name ]
  }

  routetable_ids = {
    for layer in var.subnets:
    layer => [
      for sd in local.subnet_data: 
        aws_route_table.routers[sd.name].id
    if replace( sd.name , layer, "") != sd.name ]
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

