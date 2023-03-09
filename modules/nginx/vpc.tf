data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "main" {
  cidr_block                       = "10.0.0.0/16"
  enable_dns_hostnames             = true
  assign_generated_ipv6_cidr_block = true
}

resource "aws_subnet" "first" {
  vpc_id                                         = aws_vpc.main.id
  cidr_block                                     = "10.0.1.0/24"
  ipv6_cidr_block                                = cidrsubnet(aws_vpc.main.ipv6_cidr_block, 8, 1)
  availability_zone                              = data.aws_availability_zones.available.names[0]
  assign_ipv6_address_on_creation                = true
  enable_resource_name_dns_aaaa_record_on_launch = true
  map_public_ip_on_launch                        = true
}

resource "aws_subnet" "second" {
  vpc_id                                         = aws_vpc.main.id
  cidr_block                                     = "10.0.2.0/24"
  ipv6_cidr_block                                = cidrsubnet(aws_vpc.main.ipv6_cidr_block, 8, 2)
  availability_zone                              = data.aws_availability_zones.available.names[1]
  assign_ipv6_address_on_creation                = true
  enable_resource_name_dns_aaaa_record_on_launch = true
  map_public_ip_on_launch                        = true
}

resource "aws_subnet" "third" {
  vpc_id                                         = aws_vpc.main.id
  cidr_block                                     = "10.0.3.0/24"
  ipv6_cidr_block                                = cidrsubnet(aws_vpc.main.ipv6_cidr_block, 8, 3)
  availability_zone                              = data.aws_availability_zones.available.names[2]
  assign_ipv6_address_on_creation                = true
  enable_resource_name_dns_aaaa_record_on_launch = true
  map_public_ip_on_launch                        = true
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
}

resource "aws_default_route_table" "vpc_rt" {

  default_route_table_id = aws_vpc.main.default_route_table_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_internet_gateway.gw.id
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.first.id
  route_table_id = aws_default_route_table.vpc_rt.id
}

resource "aws_route_table_association" "b" {
  subnet_id      = aws_subnet.second.id
  route_table_id = aws_default_route_table.vpc_rt.id
}

resource "aws_route_table_association" "c" {
  subnet_id      = aws_subnet.third.id
  route_table_id = aws_default_route_table.vpc_rt.id
}