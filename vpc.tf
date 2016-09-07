#========================== VPC  =============================

# Define a vpc
resource "aws_vpc" "demoVPC" {
  cidr_block = "${var.networkCIDR}"
  tags {
    Name = "${var.vpc_name}"
  }
}

# Internet gateway for the public subnet
resource "aws_internet_gateway" "demoIG" {
  vpc_id = "${aws_vpc.demoVPC.id}"
  tags {
    Name = "demoIG"
  }
}

#========================== 0.0 Subnet =============================

# Public subnet
resource "aws_subnet" "demoPubSN0-0" {
  vpc_id = "${aws_vpc.demoVPC.id}"
  cidr_block = "${var.public0-0CIDR}"
  availability_zone = "${lookup(var.availability_zone, var.region)}"
  tags {
    Name = "demoPubSN0-0-0"
  }
}

# Routing table for public subnet
resource "aws_route_table" "demoPubSN0-0RT" {
  vpc_id = "${aws_vpc.demoVPC.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.demoIG.id}"
  }
  tags {
    Name = "demoPubSN0-0RT"
  }
}

# Associate the routing table to public subnet
resource "aws_route_table_association" "demoPubSN0-0RTAssn" {
  subnet_id = "${aws_subnet.demoPubSN0-0.id}"
  route_table_id = "${aws_route_table.demoPubSN0-0RT.id}"
}
