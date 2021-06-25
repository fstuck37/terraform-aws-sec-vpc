output "vpc_id" {
  description = "The ID of the VPC"
  value = aws_vpc.main_vpc.id
}

output "subnet_ids" {
  description = "Map with keys based on the subnet names and values of subnet IDs"
  value = local.subnet_ids
}

