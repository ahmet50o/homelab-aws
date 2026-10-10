# ============================================================
# VPC
# ============================================================

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.project}-vpc"
  }
}

# ============================================================
# Internet Gateway
# ============================================================

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project}-igw"
  }
}

# ============================================================
# Subnets
# ============================================================

resource "aws_subnet" "zones" {
  for_each = var.subnet_cidrs

  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value
  availability_zone = "${var.aws_region}a"

  map_public_ip_on_launch = each.key == "public" ? true : false

  tags = {
    Name = "${var.project}-subnet-${each.key}"
  }
}

# ============================================================
# NAT Gateway (outbound internet for private subnets)
# ============================================================

resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name = "${var.project}-nat-eip"
  }
}

resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.zones["public"].id

  tags = {
    Name = "${var.project}-nat"
  }

  depends_on = [aws_internet_gateway.main]
}

# ============================================================
# Route Tables
# ============================================================

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "${var.project}-rt-public"
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
  }

  tags = {
    Name = "${var.project}-rt-private"
  }
}

# ============================================================
# Route Table Associations
# ============================================================

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.zones["public"].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  for_each = {
    for k, v in var.subnet_cidrs : k => v
    if k != "public"
  }

  subnet_id      = aws_subnet.zones[each.key].id
  route_table_id = aws_route_table.private.id
}
