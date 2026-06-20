output "alb_dns_name" {
  description = "The DNS name of the load balancer"
  value       = aws_lb.app_alb.dns_name
}

output "ecr_app_repository_url" {
  description = "The URL of the ECR repository"
  value       = aws_ecr_repository.app_ecr.repository_url
}

output "ecr_api_repository_url" {
  description = "The URL of the ECR repository"
  value       = aws_ecr_repository.api_ecr.repository_url
}

output "rds_endpoint" {
  description = "The endpoint of the RDS instance"
  value       = aws_db_instance.postgres.endpoint
}

output "private_key" {
  value     = tls_private_key.rsa_key.private_key_pem
  sensitive = true
}

output "instance_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_instance.app_server.public_ip
}