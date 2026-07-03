# Terraform Outputs
# Exposes infrastructure endpoints and configuration for application deployment

output "rds_cluster_endpoint" {
  description = "RDS Aurora cluster writer endpoint"
  value       = aws_rds_cluster.main.endpoint
  sensitive   = false
}

output "rds_cluster_reader_endpoint" {
  description = "RDS Aurora cluster reader endpoint for analytics queries"
  value       = aws_rds_cluster.main.reader_endpoint
  sensitive   = false
}

output "rds_cluster_port" {
  description = "RDS cluster port"
  value       = aws_rds_cluster.main.port
}

output "rds_database_name" {
  description = "RDS database name"
  value       = aws_rds_cluster.main.database_name
}

output "redis_primary_endpoint" {
  description = "Redis cluster primary endpoint"
  value       = aws_elasticache_replication_group.main.primary_endpoint_address
  sensitive   = false
}

output "redis_port" {
  description = "Redis cluster port"
  value       = aws_elasticache_replication_group.main.port
}

output "s3_bucket_name" {
  description = "S3 bucket for audio file storage"
  value       = aws_s3_bucket.audio_storage.bucket
}

output "s3_bucket_arn" {
  description = "S3 bucket ARN"
  value       = aws_s3_bucket.audio_storage.arn
}

output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "private_subnet_ids" {
  description = "Private subnet IDs for ECS task placement"
  value       = aws_subnet.private[*].id
}

output "public_subnet_ids" {
  description = "Public subnet IDs for ALB"
  value       = aws_subnet.public[*].id
}

output "alb_security_group_id" {
  description = "ALB security group ID"
  value       = aws_security_group.alb.id
}

output "ecs_security_group_id" {
  description = "ECS task security group ID"
  value       = aws_security_group.ecs.id
}

output "rds_security_group_id" {
  description = "RDS security group ID"
  value       = aws_security_group.rds.id
}

output "redis_security_group_id" {
  description = "Redis security group ID"
  value       = aws_security_group.redis.id
}

# Environment configuration for backend deployment
output "backend_env_vars" {
  description = "Environment variables for backend deployment"
  value = {
    DATABASE_URL  = "postgresql://${var.db_username}:${var.db_password}@${aws_rds_cluster.main.endpoint}:${aws_rds_cluster.main.port}/${aws_rds_cluster.main.database_name}"
    REDIS_URL     = "redis://:${var.redis_auth_token}@${aws_elasticache_replication_group.main.primary_endpoint_address}:${aws_elasticache_replication_group.main.port}"
    AWS_S3_BUCKET = aws_s3_bucket.audio_storage.bucket
    AWS_REGION    = var.aws_region
  }
  sensitive = true
}

# Deployment checklist
output "deployment_checklist" {
  description = "Pre-deployment checklist"
  value = {
    "1_rds_provisioned"         = true
    "2_redis_provisioned"       = true
    "3_s3_created"              = true
    "4_vpc_configured"          = true
    "5_security_groups_created" = true
    "6_next_step"               = "Deploy backend container to ECS Fargate"
  }
}
