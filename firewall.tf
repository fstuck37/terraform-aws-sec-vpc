# Config IAM role with policy
resource "aws_iam_role" "fw-iam-role" {
  name = "${var.name-vars["account"]}-${var.name-vars["name"]}-fw-iam-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}


# FW IAM Policy
resource "aws_iam_policy" "fw-iam-policy" {
  name = "${var.name-vars["account"]}-${var.name-vars["name"]}-fw-iam-policy"
  description = "IAM Policy for VM-Series Firewall"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
        {
            "Action": [
                "ec2:AttachNetworkInterface",
                "ec2:DetachNetworkInterface",
                "ec2:DescribeInstances",
                "ec2:DescribeNetworkInterfaces"
            ],
            "Resource": [
                "*"
            ],
            "Effect": "Allow"
        },
        {
            "Action": [
                "cloudwatch:PutMetricData"
            ],
            "Resource": [
                "*"
            ],
            "Effect": "Allow"
        }
    ]
}
EOF
}


resource "aws_iam_role_policy_attachment" "policy-attachment" {
  role       = aws_iam_role.fw-iam-role.name
  policy_arn = aws_iam_policy.fw-iam-policy.arn
}

resource "aws_iam_instance_profile" "iam-instance-profile" {
  name = "${var.name-vars["account"]}-${var.name-vars["name"]}-iam-profile"
  role = aws_iam_role.fw-iam-role.name
}

resource "aws_launch_template" "firewall_launch_template" {
  name          = "${var.name-vars["account"]}-${var.name-vars["name"]}-launch-template"
  image_id      = var.ami_id
  instance_type = var.instance_type
  user_data     = base64encode("mgmt-interface-swap=enable\nplugin-op-commands=aws-gwlb-inspect:enable\n${var.user_data}")
  key_name      = var.key_name

  iam_instance_profile {
      name = aws_iam_instance_profile.iam-instance-profile.name
    }

  network_interfaces {
      delete_on_termination        = true
      device_index                 = 0
      security_groups              = [aws_security_group.fw-fwt-sg.id]
  }
 
  network_interfaces {
      delete_on_termination        = true
      device_index                 = 1
      security_groups              = [aws_security_group.fw-mgt-sg.id]
  }
}

resource "aws_autoscaling_group" "firewall_asg" {
  name                 = "${var.name-vars["account"]}-${var.name-vars["name"]}-launch-configuration"
  vpc_zone_identifier  = local.subnet_ids["fwt"]
  desired_capacity     = 2
  min_size             = 2
  max_size             = 3
  launch_template {
    id      = aws_launch_template.firewall_launch_template.id
    version = "$Latest"
  }
}