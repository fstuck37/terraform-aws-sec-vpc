output "vpc_id" {
  description = "The ID of the VPC"
  value = aws_vpc.main_vpc.id
}

output "subnet_ids" {
  description = "Map with keys based on the subnet names and values of subnet IDs"
  value = local.subnet_ids
}

output "subnet_cidrs" {
  description = "Map with keys based on the subnet names and values of subnet IDs"
  value = local.subnet_cidrs
}

output "subnet_layer_cidrs" {
  description = "Map with keys based on the subnet names and values of subnet IDs"
  value = local.subnet_layer_cidrs
}

output "routetable_ids" {
  description = "Map with keys based on the subnet names and values of subnet IDs"
  value = local.routetable_ids
}