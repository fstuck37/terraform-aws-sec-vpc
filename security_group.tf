# Firewall Management Security Group
resource "aws_security_group" "fw-mgt-sg" {
  name        = "${var.name-vars["account"]}-${var.name-vars["name"]}-fw-mgt-sg"
  description = "Rules for management of Palo Firewalls"
  vpc_id      = aws_vpc.main_vpc.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.tags, 
    map("Name",format("%s","${var.name-vars["account"]}-${var.name-vars["name"]}-fw-mgt-sg"))
    )

  depends_on = [aws_vpc.main_vpc]
}

# Firewall Data Security Group
resource "aws_security_group" "fw-fwt-sg" {
  name        = "${var.name-vars["account"]}-${var.name-vars["name"]}-fw-mgt-sg"
  description = "Allow inbound traffic from GWLB"
    vpc_id      = aws_vpc.main_vpc.id

  ingress {
    from_port   = 6081
    to_port     = 6081
    protocol    = "udp"
    cidr_blocks = [var.vpc-cidrs[0]]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = merge(
    var.tags, 
    map("Name",format("%s","${var.name-vars["account"]}-${var.name-vars["name"]}-fw-fwt-sg"))
    )

  depends_on = [aws_vpc.main_vpc]
}