resource "aws_db_instance" "my_desonc_db_read_replica" {
  identifier                 = "my-desonc-db-read-replica"
  replicate_source_db        = aws_db_instance.my_desonc_db_instance.arn
  instance_class             = "db.t3.micro"
  db_subnet_group_name       = aws_db_subnet_group.my_desonc_db_subnet_group.name
  vpc_security_group_ids     = [aws_security_group.my_desonc_db_security_group.id]
  parameter_group_name       = aws_db_parameter_group.my_desonc_db_parameter_group.name
  publicly_accessible        = false
  auto_minor_version_upgrade = true
  apply_immediately          = true
}