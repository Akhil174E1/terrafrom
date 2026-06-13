resource "aws_security_group" "my_desonc_db_security_group" {
  name        = "my-desonc-db-security-group"
  description = "Security group for My Desonc DB instance"
  vpc_id      = aws_vpc.custom_vpc.id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.custom_vpc.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_subnet_group" "my_desonc_db_subnet_group" {
  name       = "my-desonc-db-subnet-group"
  subnet_ids = [aws_subnet.private_subnet_01.id, aws_subnet.private_subnet_02.id]
}

resource "aws_db_parameter_group" "my_desonc_db_parameter_group" {
  name   = "my-desonc-mysql8-parameter-group"
  family = "mysql8.0"

  parameter {
    name  = "log_output"
    value = "FILE"
  }

  parameter {
    name  = "general_log"
    value = "1"
  }

  parameter {
    name  = "slow_query_log"
    value = "1"
  }
}

resource "aws_cloudwatch_log_group" "rds_logs" {
  name              = "/rds.logs"
  retention_in_days = 14
}

resource "aws_db_instance" "my_desonc_db_instance" {
  identifier                      = "my-desonc-db-instance"
  allocated_storage               = 20
  storage_type                    = "gp2"
  storage_encrypted               = true
  engine                          = "mysql"
  engine_version                  = "8.0"
  instance_class                  = "db.t3.micro"
  db_subnet_group_name            = aws_db_subnet_group.my_desonc_db_subnet_group.name
  vpc_security_group_ids          = [aws_security_group.my_desonc_db_security_group.id]
  username                        = "admin"
  password                        = "password1234"
  parameter_group_name            = aws_db_parameter_group.my_desonc_db_parameter_group.name
  skip_final_snapshot             = true
  publicly_accessible             = false
  backup_retention_period         = 7
  enabled_cloudwatch_logs_exports = ["error", "general", "slowquery"]

  depends_on = [aws_cloudwatch_log_group.rds_logs]
}