resource "aws_vpc" "main_vpc" {
  cidr_block           = var.vpc-cidrs[0]
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support
  instance_tenancy     = var.instance_tenancy
  tags                 = merge(
    var.tags,
    map("Name",format("%s", var.vpc-name == true ? "${var.name-vars["account"]}-${replace(var.region,"-", "")}-${var.name-vars["name"]}" : var.vpc-name)),
    local.resource-tags["aws_vpc"]
  )
}

resource "aws_vpc_ipv4_cidr_block_association" "secondary_cidrs" {
  for_each   = length(var.vpc-cidrs)> 1 ? toset(slice(var.vpc-cidrs, 1, length(var.vpc-cidrs)-1)) : toset([])
  vpc_id     = aws_vpc.main_vpc.id
  cidr_block = each.value
}