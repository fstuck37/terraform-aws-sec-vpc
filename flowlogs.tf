resource "aws_flow_log" "vpc_flowlog" {
  count = var.enable_flowlog ? 1 : 0
  vpc_id = aws_vpc.main_vpc.id
  log_destination = aws_cloudwatch_log_group.flowlog_group.0.arn
  iam_role_arn = aws_iam_role.flowlog_role.0.arn
  traffic_type = "ALL"
}

resource "aws_cloudwatch_log_group" "flowlog_group" {
  count = var.enable_flowlog ? 1 : 0
  name = aws_vpc.main_vpc.id
  retention_in_days = var.cloudwatch_retention_in_days
  tags = merge(
    var.tags,
    map("Name","${var.name-vars["account"]}-${replace(var.region,"-", "")}-${var.name-vars["name"]}-log"),
    local.resource-tags["aws_cloudwatch_log_group"]
    )
}

resource "aws_iam_role" "flowlog_role" {
  count = var.enable_flowlog ? 1 : 0
  name = "${var.name-vars["account"]}-${replace(var.region,"-", "")}-${var.name-vars["name"]}-flow-log-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "vpc-flow-logs.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
} 
EOF
}

resource "aws_iam_role_policy" "flowlog_write" {
  count = var.enable_flowlog ? 1 : 0
  name = "${var.name-vars["account"]}-${replace(var.region,"-", "")}-${var.name-vars["name"]}-write-to-cloudwatch"
  role = aws_iam_role.flowlog_role.0.id
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}   
EOF
}

resource "aws_iam_role" "flowlog_subscription_role" {
  count = var.enable_flowlog ? 1 : 0

  name = "${var.name-vars["account"]}-${replace(var.region,"-", "")}-${var.name-vars["name"]}-flow-log-subscription-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "logs.${var.region}.${var.amazonaws-com}"
      },
      "Action": "sts:AssumeRole"
    }
  ]
} 
EOF
}

resource "aws_cloudwatch_log_subscription_filter" "flow_logs_destination" {
  count = var.enable_flowlog && !(var.flowlog_destination_arn == "none" ) ? 1 : 0
  name = "vpc-${aws_vpc.main_vpc.id}-logfilter"
  log_group_name = aws_cloudwatch_log_group.flowlog_group.0.name
  filter_pattern = var.flow_log_filter
  destination_arn = var.flowlog_destination_arn
}