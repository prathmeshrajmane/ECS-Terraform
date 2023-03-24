resource "aws_vpc" "vpc" {
  cidr_block              = var.vpc-cidr
    instance_tenancy      = var.instanceTenancy
    enable_dns_support    = var.dnsSupport
    enable_dns_hostnames  = var.dnsHostNames
  tags = merge(
  var.tags,
  tomap({"Name" = "${var.env_name}-${var.vpc-name}"})
)
}

resource "aws_eip" "nat" {
  vpc      = true
}

resource "aws_subnet" "apes-public-subnet" {
  count                   = length(var.public-subnets-cidr)
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = element(var.public-subnets-cidr, count.index)
  map_public_ip_on_launch = true
  tags = merge(
  var.tags,
  tomap({"Name" = "${var.env_name}-${var.public-subnet-name}"})
)
}

resource "aws_subnet" "apes-private-subnet" {
  count                   = length(var.private-subnets-cidr)
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = element(var.private-subnets-cidr, count.index)
  availability_zone       = element(var.azs, count.index)
  map_public_ip_on_launch = false
  tags = merge(
  var.tags,
  tomap({"Name" = "${var.env_name}-${var.private-subnet-name}"})
)
}

resource "aws_internet_gateway" "apes-internet-gateway" {
  vpc_id                  = aws_vpc.vpc.id

  tags = merge(
  var.tags,
  tomap({"Name" = "${var.env_name}-${var.internet-gateway-name}"})
)
}

resource "aws_nat_gateway" "apes-nat-gateway" {
  connectivity_type       = var.natConnectivity
  allocation_id           = aws_eip.nat.id
  subnet_id               = aws_subnet.apes-public-subnet.*.id[0]
  tags = merge(
  var.tags,
  tomap({"Name" = "${var.env_name}-${var.nat-gateway-name}"})
)
}

resource "aws_route_table" "apes-public-rt" {
  vpc_id                  = aws_vpc.vpc.id

  route {
    cidr_block            = var.public-cidr
    gateway_id            = aws_internet_gateway.apes-internet-gateway.id
  }
  tags = merge(
    var.tags,
    tomap({ "Name" = "${var.env_name}-${var.public-rt-name }"})
  )
}

resource "aws_route_table_association" "apes-public-rt-association" {
    subnet_id             = aws_subnet.apes-public-subnet.*.id[0]
    route_table_id        = aws_route_table.apes-public-rt.id
}

resource "aws_route_table" "apes-private-rt" {
  depends_on = [aws_subnet.apes-private-subnet, aws_nat_gateway.apes-nat-gateway]
  vpc_id                  = aws_vpc.vpc.id

  route {
    cidr_block            = var.public-cidr
    gateway_id            = aws_nat_gateway.apes-nat-gateway.id
  }
  tags = merge(
    var.tags,
    tomap({ "Name" = "${var.env_name}-${var.private-rt-name }"})
  )
}

resource "aws_route_table_association" "apes-private-rt-association" {
    count = "${length(var.private-subnets-cidr)}"
    subnet_id             = "${element(aws_subnet.apes-private-subnet.*.id, count.index)}"
    route_table_id        = aws_route_table.apes-private-rt.id
}

resource "aws_security_group" "apes-sg" {
  depends_on              = [aws_subnet.apes-private-subnet]
  name                    = "apes-sg"
  description             = "Creating a security group"
  vpc_id                  = aws_vpc.vpc.id

  ingress {
    description           = "TLS from VPC"
    from_port             = 443
    to_port               = 443
    protocol              = "tcp"
    cidr_blocks           = [var.vpc-cidr]

  }
  ingress {
    description           = "TLS from VPC"
    from_port             = 80
    to_port               = 80
    protocol              = "tcp"
    cidr_blocks           = [var.vpc-cidr]

  }
  ingress {
    description           = "For RTMP Inbound Access"
    from_port             = 1935
    to_port               = 1935
    protocol              = "tcp"
    cidr_blocks           = [var.vpc-cidr]

  }


  egress {
    description           = "TLS from VPC"
    from_port             = 443
    to_port               = 443
    protocol              = "tcp"
    cidr_blocks           = [var.public-cidr]
  }
  egress {
    description           = "TLS from VPC"
    from_port             = 80
    to_port               = 80
    protocol              = "tcp"
    cidr_blocks           = [var.public-cidr]
  }
  egress {
    description           = "For RTMP Outbound Access"
    from_port             = 1935
    to_port               = 1935
    protocol              = "tcp"
    cidr_blocks           = [var.public-cidr]
  }


  tags = merge(
    var.tags,
    tomap({ "Name" = "${var.env_name}-${var.apes-sg-name }"})
  )
}

resource "aws_vpc_endpoint" "apes-vpc-endpoint-s3" {
  vpc_id       = aws_vpc.vpc.id
  service_name = "com.amazonaws.us-east-1.s3"
  tags = merge(
    var.tags,
    tomap({"Name" = "${var.env_name}-${var.vpc-endpoint-name}"})
  )
}

resource "aws_vpc_endpoint_route_table_association" "apes-vpc-endpoint-rt-association" {
  route_table_id  = aws_route_table.apes-private-rt.id
  vpc_endpoint_id = aws_vpc_endpoint.apes-vpc-endpoint-s3.id
}


resource "aws_eip" "eni" {
  vpc = true
}

