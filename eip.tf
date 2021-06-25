resource "aws_eip" "eip" {
  for_each = toset(data.aws_availability_zones.azs.names)
  vpc = true
}






