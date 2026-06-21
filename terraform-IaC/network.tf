resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "${var.environment}-vpc"
  }
}

resource "aws_subnet" "public_az_1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(aws_vpc.main.cidr_block, 4, 1)
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.environment}-public-az-1"
  }
}

resource "aws_subnet" "public_az_2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(aws_vpc.main.cidr_block, 4, 2)
  availability_zone       = "${var.aws_region}b"
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.environment}-public-az-2"
  }
}

resource "aws_subnet" "private_az_1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(aws_vpc.main.cidr_block, 4, 3)
  availability_zone = "${var.aws_region}a"
  tags = {
    Name = "${var.environment}-private-az-1"
  }
}

resource "aws_subnet" "private_az_2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(aws_vpc.main.cidr_block, 4, 4)
  availability_zone = "${var.aws_region}b"
  tags = {
    Name = "${var.environment}-private-az-2"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.environment}-igw"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "${var.environment}-public-route-table"
  }
}

# Route table association
resource "aws_route_table_association" "public_1" {
  subnet_id      = aws_subnet.public_az_1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_2" {
  subnet_id      = aws_subnet.public_az_2.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.environment}-private-route-table"
  }
}

resource "aws_route_table_association" "private_1" {
  subnet_id      = aws_subnet.private_az_1.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_2" {
  subnet_id      = aws_subnet.private_az_2.id
  route_table_id = aws_route_table.private.id
}