# ─── RDS Subnet Group ─────────────────────────────────────────────────────────

resource "aws_db_subnet_group" "sb-group" {
  name = "${var.project_name}-db-subnet-group"
  # FIX: was passing resource objects — must use .id
  subnet_ids = [
    aws_subnet.private-rds-01.id,
    aws_subnet.private-rds-02.id,
  ]

  tags = { Name = "${var.project_name}-db-subnet-group" }
}

# ─── RDS Parameter Group ──────────────────────────────────────────────────────

resource "aws_db_parameter_group" "mysql" {         # ENHANCEMENT: explicit param group
  name   = "${var.project_name}-mysql8"
  family = "mysql8.0"

  parameter {
    name  = "character_set_server"
    value = "utf8mb4"
  }

  parameter {
    name  = "collation_server"
    value = "utf8mb4_unicode_ci"
  }

  tags = { Name = "${var.project_name}-mysql-params" }
}

# ─── RDS Instance ─────────────────────────────────────────────────────────────

resource "aws_db_instance" "default" {
  identifier        = var.identifier
  allocated_storage = 20
  db_name           = var.db_name
  engine            = "mysql"
  engine_version    = "8.0"
  instance_class    = "db.t3.micro"

  # FIX: vpc_security_group_ids needs a list of SG IDs, not the subnet group resource
  vpc_security_group_ids = [aws_security_group.sg-rds.id]

  # FIX: db_subnet_group_name needs the NAME (string), not the resource object
  db_subnet_group_name = aws_db_subnet_group.sb-group.name

  username             = var.user_name
  password             = var.password
  parameter_group_name = aws_db_parameter_group.mysql.name

  # ENHANCEMENT: production-ready settings
  multi_az               = true               # high availability across 2 AZs
  storage_encrypted      = true               # encrypt at rest
  backup_retention_period = 7                 # 7-day automated backups
  deletion_protection    = false              # set true for production
  skip_final_snapshot    = true               # set false for production

  tags = { Name = "${var.project_name}-rds" }
}
