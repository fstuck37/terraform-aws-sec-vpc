resource "aws_eip" "eip" {
  for_each = data.aws_availability_zones.azs.names
  vpc = true
}






