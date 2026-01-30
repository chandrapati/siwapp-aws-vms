# create-vpc.tf

resource "aws_vpc" "vpc" {
  cidr_block           = "10.255.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    "Owner" = "sujit"
    "Name"  = "siwapp-vpc"
  }
}