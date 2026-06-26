# ─── Security Groups ──────────────────────────────────────────────────────────

# ENHANCEMENT: Separate, least-privilege security groups per tier
# (keeping your open SG for testing, but adding proper ones alongside)

resource "aws_security_group" "sg-open" {
  name        = "${var.project_name}-open-sg"
  description = "wide-open sg"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.project_name}-open-sg" }
}

resource "aws_security_group" "sg-bastion" {
  name        = "${var.project_name}-bastion-sg"
  description = "Allow SSH to bastion only from your IP"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH from admin CIDR"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.admin_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.project_name}-bastion-sg" }
}

resource "aws_security_group" "sg-frontend" {
  name        = "${var.project_name}-frontend-sg"
  description = "Allow HTTP/S from external ALB; SSH from bastion"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "HTTP from external ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.sg-lb-external.id]
  }

  ingress {
    description     = "SSH from bastion"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.sg-bastion.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.project_name}-frontend-sg" }
}

resource "aws_security_group" "sg-backend" {
  name        = "${var.project_name}-backend-sg"
  description = "Allow app port from internal ALB; SSH from bastion"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "App port from internal ALB"
    from_port       = var.app_port
    to_port         = var.app_port
    protocol        = "tcp"
    security_groups = [aws_security_group.sg-lb-internal.id]
  }

  ingress {
    description     = "SSH from bastion"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.sg-bastion.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.project_name}-backend-sg" }
}

resource "aws_security_group" "sg-rds" {
  name        = "${var.project_name}-rds-sg"
  description = "Allow MySQL only from backend SG"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "MySQL from backend"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.sg-backend.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.project_name}-rds-sg" }
}

resource "aws_security_group" "sg-lb-external" {
  name        = "${var.project_name}-lb-external-sg"
  description = "Allow HTTP/HTTPS from internet"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.project_name}-lb-external-sg" }
}

resource "aws_security_group" "sg-lb-internal" {
  name        = "${var.project_name}-lb-internal-sg"
  description = "Allow app port from frontend SG"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "From frontend instances"
    from_port       = var.app_port
    to_port         = var.app_port
    protocol        = "tcp"
    security_groups = [aws_security_group.sg-frontend.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.project_name}-lb-internal-sg" }
}

# ─── Key Pair ─────────────────────────────────────────────────────────────────

resource "aws_key_pair" "main" {                    # ENHANCEMENT: SSH key pair
  key_name   = "${var.project_name}-key"
  public_key = var.public_key
}

# ─── EC2 Instances ────────────────────────────────────────────────────────────

resource "aws_instance" "frontend-01" {
  ami                    = var.ami_id
  instance_type          = var.inst_type
  subnet_id              = aws_subnet.private-front-01.id   # FIX: missing .id
  vpc_security_group_ids = [aws_security_group.sg-open.id]  # FIX: missing .id; use list
  key_name               = aws_key_pair.main.key_name

  tags = { Name = "${var.project_name}-frontend-01" }
}

resource "aws_instance" "frontend-02" {
  ami                    = var.ami_id
  instance_type          = var.inst_type
  subnet_id              = aws_subnet.private-front-02.id   # FIX: missing .id
  vpc_security_group_ids = [aws_security_group.sg-open.id]
  key_name               = aws_key_pair.main.key_name

  tags = { Name = "${var.project_name}-frontend-02" }
}

resource "aws_instance" "backend-01" {
  ami                    = var.ami_id
  instance_type          = var.inst_type
  subnet_id              = aws_subnet.private-back-01.id    # FIX: missing .id
  vpc_security_group_ids = [aws_security_group.sg-open.id]
  key_name               = aws_key_pair.main.key_name

  tags = { Name = "${var.project_name}-backend-01" }
}

resource "aws_instance" "backend-02" {
  ami                    = var.ami_id
  instance_type          = var.inst_type
  subnet_id              = aws_subnet.private-back-02.id    # FIX: missing .id
  vpc_security_group_ids = [aws_security_group.sg-open.id]
  key_name               = aws_key_pair.main.key_name

  tags = { Name = "${var.project_name}-backend-02" }
}

resource "aws_instance" "bastion-host" {
  ami                    = var.ami_id
  instance_type          = var.inst_type
  subnet_id              = aws_subnet.public-front-01.id    # FIX: missing .id
  vpc_security_group_ids = [aws_security_group.sg-open.id]
  key_name               = aws_key_pair.main.key_name

  tags = { Name = "${var.project_name}-bastion-host" }
}

# ENHANCEMENT: Elastic IP for bastion so its public IP doesn't change on restart
resource "aws_eip" "bastion" {
  instance = aws_instance.bastion-host.id
  domain   = "vpc"

  tags = { Name = "${var.project_name}-bastion-eip" }
}
