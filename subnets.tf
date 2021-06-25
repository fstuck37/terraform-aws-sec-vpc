resource "aws_subnet" "subnets" {
  for_each = {for i in local.subnet_data:i.name=>i}
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = each.value.subnet
  availability_zone = each.value.az
  tags              = merge(
    var.tags, 
    map("Name", each.value.name ),
    local.resource-tags["aws_subnet"]
  )
}

