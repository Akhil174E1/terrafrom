output "rds_endpoint" {
  value = aws_db_instance.my_desonc_db_instance.address
}

output "rds_read_replica_endpoint" {
  value = aws_db_instance.my_desonc_db_read_replica.address
}

output "elasticache_endpoint" {
  value = aws_elasticache_cluster.my_desonc_cache_cluster.cache_nodes[0].address
}

output "rds_cloudwatch_log_group" {
  value = aws_cloudwatch_log_group.rds_logs.name
}
