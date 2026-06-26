# VPC
resource "aws_vpc" "custom_vpc" {
  enable_dns_support   = true
  enable_dns_hostnames = true
  cidr_block = "10.0.0.0/16"
}

# Subnets
resource "aws_subnet" "public_subnet-01" {
  vpc_id                  = aws_vpc.custom_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "public_subnet-02" {
  vpc_id                  = aws_vpc.custom_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true
}

# ✅ Internet Gateway — ADDED
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.custom_vpc.id
}

# ✅ Route Table — ADDED
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.custom_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

# ✅ Route Table Associations — ADDED
resource "aws_route_table_association" "rta_01" {
  subnet_id      = aws_subnet.public_subnet-01.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "rta_02" {
  subnet_id      = aws_subnet.public_subnet-02.id
  route_table_id = aws_route_table.public_rt.id
}

# Security Group — Fixed port
resource "aws_security_group" "db_security_group" {
  name        = "db_security_group"
  description = "Allow MySQL traffic"
  vpc_id      = aws_vpc.custom_vpc.id

  # ✅ Only MySQL port — FIXED
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# DB Subnet Group
resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "db_subnet_group"
  subnet_ids = [aws_subnet.public_subnet-01.id, aws_subnet.public_subnet-02.id]
}

# RDS Instance
resource "aws_db_instance" "db_instance" {
  identifier             = "mydbinstance"
  allocated_storage      = 20
  storage_type           = "gp2"
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t3.micro"
  username               = "admin"
  password               = "Akhil123"   # ✅ Use variable — FIXED
  parameter_group_name   = "default.mysql8.0"
  db_subnet_group_name   = aws_db_subnet_group.db_subnet_group.name
  vpc_security_group_ids = [aws_security_group.db_security_group.id]
  skip_final_snapshot    = true
  publicly_accessible    = true              # ✅ ADDED
  final_snapshot_identifier = "mydbinstance-final-snapshot"
}

# Null Resource
resource "null_resource" "rds_provisioner" {
  depends_on = [aws_db_instance.db_instance]

  provisioner "local-exec" {
    command = "echo 'RDS instance created! Endpoint: ${aws_db_instance.db_instance.endpoint}'"
  }
}