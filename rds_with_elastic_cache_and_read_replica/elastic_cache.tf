resource "aws_elasticache_subnet_group" "my_desonc_cache_subnet_group" {
  name       = "my-desonc-cache-subnet-group"
  subnet_ids = [aws_subnet.private_subnet_01.id, aws_subnet.private_subnet_02.id]
}

resource "aws_security_group" "my_desonc_cache_security_group" {
  name        = "my-desonc-cache-security-group"
  description = "Security group for My Desonc Redis cache"
  vpc_id      = aws_vpc.custom_vpc.id

  ingress {
    from_port   = 6379
    to_port     = 6379
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

resource "aws_elasticache_cluster" "my_desonc_cache_cluster" {
  cluster_id           = "my-desonc-cache-cluster"
  engine               = "redis"
  engine_version       = "6.x"
  node_type            = "cache.t3.micro"
  num_cache_nodes      = 1
  port                 = 6379
  parameter_group_name = "default.redis6.x"
  subnet_group_name    = aws_elasticache_subnet_group.my_desonc_cache_subnet_group.name
  security_group_ids   = [aws_security_group.my_desonc_cache_security_group.id]
}