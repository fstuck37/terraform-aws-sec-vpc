data "aws_availability_zones" "azs" {
  state = "available"
}

locals {
  emptymaps = [{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{}]
  resource_list = ["aws_vpc", "aws_vpn_gateway", "aws_subnet", "aws_network_acl", "aws_internet_gateway", "aws_cloudwatch_log_group", "aws_vpc_dhcp_options", "aws_route_table", "aws_route53_resolver_endpoint", "aws_lb"]
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
        layer_cidr = cidrsubnet(var.vpc-cidrs[0] , ceil( log(max(length(var.subnets), var.max_layers),2)) , i )
        subnet_cidr = cidrsubnet(   cidrsubnet(var.vpc-cidrs[0] , ceil( log(max(length(var.subnets), var.max_layers),2)) , i )   , (var.subnet_size - (element(split("/", var.vpc-cidrs[0]),1) + ceil(log(max(length(data.aws_availability_zones.azs.names), var.max_azs),2)))) , ii )
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

  subnet_layer_cidrs = {
    for layer in var.subnets:
    layer => distinct([
      for sd in local.subnet_data: 
        sd.layer_cidr
    if sd.layer == layer ])[0]
  }

  routetable_ids = {
    for layer in var.subnets:
    layer => [
      for sd in local.subnet_data:
        aws_route_table.routers[sd.name].id
    if sd.layer == layer ]
  }

  tgw_routes = flatten([
    for rt in aws_route_table.routers : [
      for r in var.internal_networks : {
        name  = rt.tags["Name"]
        route = r
        index = "${rt.tags["Name"]}-${r}"
     }
    if replace(rt.tags["Name"], "tgw", "") != rt.tags["Name"]  ]
  ])
}

        
