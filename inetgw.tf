resource "aws_internet_gateway" "inet-gw" {
  vpc_id = aws_vpc.main_vpc.id
  tags = merge(
    var.tags,
    map("Name",format("%s", "${var.name-vars["account"]}-${var.name-vars["name"]}-${replace(var.region,"-", "")}-igw" )),
    local.resource-tags["aws_internet_gateway"]
  )
}