resource "aws_egress_only_internet_gateway" "eg-inet-gw" {
  vpc_id = aws_vpc.main_vpc.id
  tags = merge(
    var.tags,
    map("Name",format("%s", "${var.name-vars["account"]}-${var.name-vars["name"]}-${replace(var.region,"-", "")}-igw" )),
    local.resource-tags["aws_internet_gateway"],
    local.resource-tags["aws_egress_only_internet_gateway"]
  )
}