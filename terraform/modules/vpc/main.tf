resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
}

resource "aws_subnet" "private" {
  count             = length(var.private_subnets)
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.private_subnets[count.index]
  availability_zone = element(["ap-south-1a", "ap-south-1b"], count.index)
}

# 1. Add Internet Gateway
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id
}

# 2. Add a Public Subnet (NAT Gateway must live here)
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = "10.0.10.0/24" # Use a new range like this
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = true
}

# 3. Add Elastic IP and NAT Gateway
resource "aws_eip" "nat" {
  domain = "vpc"
}

resource "aws_nat_gateway" "this" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public.id
  depends_on    = [aws_internet_gateway.this]
}

# 4. Route Private Subnets to the NAT Gateway
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.this.id
  }
}

resource "aws_route_table_association" "private" {
  count          = length(aws_subnet.private)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}

# 1. Create a Route Table for the Public Subnet
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id # Point to IGW
  }

  tags = {
    Name = "ecommerce-public-rt"
  }
}

# 2. Associate the Public Subnet with this Route Table
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

