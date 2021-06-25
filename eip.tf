##################################################
# File: eip.tf                                   #
# Created Date: 03192019                         #
# Author: Fred Stuck                             #
# Version: 0.1                                   #
# Description: Creates an Elastic IP             #
#                                                #
# Change History:                                #
# 03192019: Initial File                         #
#                                                #
##################################################

resource "aws_eip" "eip" {
  for_each = data.aws_availability_zones.azs.names
  vpc = true
}






