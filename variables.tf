variable "region" {
  type = string
  description = "Required : The AWS Region to deploy the VPC to"
}

variable "vpc-cidrs" {
  description = "Required : List of CIDRs to apply to the VPC. Only the first CIDR is used for the calculated networks. All other subnets would need to created outside of the module. The first CIDR must have enough /26s to deploy 5 subnets in each availability zone."
  type = list(string)
  default = ["10.0.0.0/20"]
}

variable "name-vars" {
  description = "Required : Map with two keys account and name. Names of elements are created based on these values."
  type = map(string)
}

variable "tags" {
  type = map(string)
  description = "Optional : A map of tags to assign to the resource."
  default = {}
}

variable "resource-tags" {
  type = map(map(string))
  description = "Optional : A map of maps of tags to assign to specifc resources.  The key must be one of the following: aws_vpc, aws_vpn_gateway, aws_subnet, aws_network_acl, aws_internet_gateway, aws_cloudwatch_log_group, aws_vpc_dhcp_options, aws_route_table."
  default = { }
}

variable "vpc-name" {
  description = "Optional : Override the calculated VPC name."
  default     = true
}

variable "enable_dns_support" {
  description = "Optional : A boolean flag to enable/disable DNS support in the VPC. Defaults true."
  default     = true
}

variable "enable_dns_hostnames" {
  description = "Optional : A boolean flag to enable/disable DNS hostnames in the VPC. Defaults false."
  default     = true
}

variable "instance_tenancy" {
  type        = string
  description = "Optional : A tenancy option for instances launched into the VPC."
  default     = "default"
}

variable "subnets" {
  type = list(string)
  description = "Optional : List of subnet identifiers for each of the subnet 5 layers that are required."
  default = ["ngw", "fwt", "tgw", "gwe", "mgt"]
}

variable "subnet_size" {
  description = "Optional : The size of each of the subnets in each availability zone. The default is 26."
  default = 26
}

variable "az_growth" {
   description = "Optional : The number of extra availability zones to add to the calculation for subnet sizes. This allows for AZ growth without redeployment. The default is 1."
   default = 1
}

variable "domain_name" {
	description = "Optional : DNS search domains for DHCP Options. You can use <VPCID> in the text which will be repalced by the VPC ID."
	default = "ec2.internal"
}

variable "domain_name_servers" {
	description = "Optional : DNS Servers for DHCP Options"
	default = ["AmazonProvidedDNS"]
}

variable "ntp_servers" {
	description = "Optional : NTP Servers for DHCP Options"
	default = []
}

variable "dx_gateway_id" {
	description = "Optional : specify the Direct Connect Gateway ID to associate the VGW with."
	default     = false
}

variable "transit_gateway_id" {
	description = "Optional : specify the Transit Gateway ID within the same account to associate the VPC with."
	default     = false
}

variable "transit_gateway_routes" {
	type = list(string)
	description = "Optional : specify the networks to route to the Transit Gateway"
	default     = []
}

variable "enable_flowlog" {
	description = "Optional : A boolean flag to enable/disable VPC flowlogs."
	default     = true
}

variable "flowlog_destination_arn" {
	description = "Optional : The ARN of the destination resource for flowlog subscription"
	default     = "none"
}

variable "flow_log_filter" {
	description = "CloudWatch subscription filter to match flow logs."
	default = "[version, account, eni, source, destination, srcport, destport, protocol, packets, bytes, windowstart, windowend, action, flowlogstatus]"
}

variable "cloudwatch_retention_in_days" {
	description = "Optional : Number of days to keep logs within the cloudwatch log_group. The default is 7 days."
	default = "7"
}

variable "appliance_mode_support" {
	description = "(Optional) Whether Appliance Mode support is enabled. If enabled, a traffic flow between a source and destination uses the same Availability Zone for the VPC attachment for the lifetime of that flow. Valid values: disable, enable. Default value: disable."
	default     = "disable"
}

variable "amazonaws-com" {
	description = "Optional : Ability to change principal for flowlogs from amazonaws.com to amazonaws.com.cn."
	default = "amazonaws.com"
}