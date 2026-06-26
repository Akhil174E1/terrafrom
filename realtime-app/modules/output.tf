output "external_alb_dns" {
  description = "DNS of the public-facing load balancer — point your domain here"
  value       = aws_lb.lb-external.dns_name
}

output "internal_alb_dns" {
  description = "DNS of the internal load balancer — configure in frontend app"
  value       = aws_lb.lb-internal.dns_name
}

output "bastion_public_ip" {
  description = "Public IP of the bastion host for SSH tunnelling"
  value       = aws_eip.bastion.public_ip
}

output "rds_endpoint" {
  description = "RDS MySQL endpoint — configure in backend app"
  value       = aws_db_instance.default.endpoint
  sensitive   = true
}

output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}
