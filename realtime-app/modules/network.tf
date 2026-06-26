resource "aws_vpc" "main" {
  cidr_block           = var.cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.project_name}-vpc"
  }
}

# ─── Public Subnets ────────────────────────────────────────────────────────────

resource "aws_subnet" "public-front-01" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "${var.aws_region}a"   # FIX: AZ required for LB & HA
  map_public_ip_on_launch = true

  tags = { Name = "${var.project_name}-public-front-01" }
}

resource "aws_subnet" "public-front-02" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "${var.aws_region}b"   # ENHANCEMENT: second AZ for ALB
  map_public_ip_on_launch = true

  tags = { Name = "${var.project_name}-public-front-02" }
}

# ─── Private Frontend Subnets ─────────────────────────────────────────────────

resource "aws_subnet" "private-front-01" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.10.0/24"    # FIX: was /32-like "10.0.0.0/24" colliding blocks
  availability_zone = "${var.aws_region}a"

  tags = { Name = "${var.project_name}-private-front-01" }
}

resource "aws_subnet" "private-front-02" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.11.0/24"   # FIX: was "10.0.0.1/24" — not a valid subnet
  availability_zone = "${var.aws_region}b"

  tags = { Name = "${var.project_name}-private-front-02" }
}

# ─── Private Backend Subnets ──────────────────────────────────────────────────

resource "aws_subnet" "private-back-01" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.20.0/24"   # FIX: was "10.0.0.2/24"
  availability_zone = "${var.aws_region}a"

  tags = { Name = "${var.project_name}-private-back-01" }
}

resource "aws_subnet" "private-back-02" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.21.0/24"   # FIX: was "10.0.0.3/24"
  availability_zone = "${var.aws_region}b"

  tags = { Name = "${var.project_name}-private-back-02" }
}

# ─── Private RDS Subnets ──────────────────────────────────────────────────────

resource "aws_subnet" "private-rds-01" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.30.0/24"   # FIX: was "10.0.0.4/24"
  availability_zone = "${var.aws_region}a"

  tags = { Name = "${var.project_name}-private-rds-01" }
}

resource "aws_subnet" "private-rds-02" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.31.0/24"   # FIX: was "10.0.0.5/24"
  availability_zone = "${var.aws_region}b"

  tags = { Name = "${var.project_name}-private-rds-02" }
}

# ─── Internet Gateway ─────────────────────────────────────────────────────────

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = { Name = "${var.project_name}-igw" }
}

# ─── Elastic IP + NAT Gateway ─────────────────────────────────────────────────

resource "aws_eip" "main" {                         # FIX: was missing entirely
  domain = "vpc"

  tags = { Name = "${var.project_name}-eip" }
}

resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.main.id
  subnet_id     = aws_subnet.public-front-01.id

  depends_on = [aws_internet_gateway.main]          # ENHANCEMENT: explicit dependency

  tags = { Name = "${var.project_name}-nat" }
}

# ─── Public Route Table ───────────────────────────────────────────────────────

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = { Name = "${var.project_name}-public-rt" }
}

resource "aws_route_table_association" "public-front-01" {
  subnet_id      = aws_subnet.public-front-01.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public-front-02" {
  subnet_id      = aws_subnet.public-front-02.id
  route_table_id = aws_route_table.public.id
}

# ─── Private Route Table ──────────────────────────────────────────────────────

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id        # FIX: was gateway_id (wrong key for NAT)
  }

  tags = { Name = "${var.project_name}-private-rt" }
}

resource "aws_route_table_association" "private-front-01" {
  subnet_id      = aws_subnet.private-front-01.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private-front-02" {
  subnet_id      = aws_subnet.private-front-02.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private-back-01" {
  subnet_id      = aws_subnet.private-back-01.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private-back-02" {
  subnet_id      = aws_subnet.private-back-02.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private-rds-01" {
  subnet_id      = aws_subnet.private-rds-01.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private-rds-02" {
  subnet_id      = aws_subnet.private-rds-02.id
  route_table_id = aws_route_table.private.id
}
