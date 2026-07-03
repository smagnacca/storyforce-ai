# StoryForce.AI Terraform Outputs
# Provides key infrastructure endpoints and identifiers

# ============================================================================
# VPC OUTPUTS
# ============================================================================
output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

# ============================================================================
# RDS OUTPUTS (when enable_rds = true)
# ============================================================================
output "rds_cluster_endpoint" {
  description = "RDS cluster endpoint"
  value       = var.enable_rds ? aws_rds_cluster.main[0].endpoint : null
  sensitive   = false
}

output "rds_cluster_reader_endpoint" {
  description = "RDS cluster reader endpoint"
  value       = var.enable_rds ? aws_rds_cluster.main[0].reader_endpoint : null
  sensitive   = false
}

output "rds_cluster_port" {
  description = "RDS cluster port"
  value       = var.enable_rds ? aws_rds_cluster.main[0].port : null
}

output "rds_database_name" {
  description = "RDS database name"
  value       = var.enable_rds ? aws_rds_cluster.main[0].database_name : null
}

# ============================================================================
# ELASTICACHE OUTPUTS (when enable_elasticache = true)
# ============================================================================
output "redis_primary_endpoint" {
  description = "Redis primary endpoint address"
  value       = var.enable_elasticache ? aws_elasticache_replication_group.main[0].primary_endpoint_address : null
  sensitive   = false
}

output "redis_port" {
  description = "Redis port"
  value       = var.enable_elasticache ? aws_elasticache_replication_group.main[0].port : null
}

# ============================================================================
# S3 OUTPUTS
# ============================================================================
output "s3_bucket_name" {
  description = "S3 bucket for audio storage"
  value       = aws_s3_bucket.audio_storage.id
}

output "s3_bucket_arn" {
  description = "S3 bucket ARN"
  value       = aws_s3_bucket.audio_storage.arn
}

# ============================================================================
# SECURITY GROUP OUTPUTS
# ============================================================================
output "alb_security_group_id" {
  description = "ALB security group ID"
  value       = var.enable_alb ? aws_security_group.alb[0].id : null
}

output "ecs_security_group_id" {
  description = "ECS security group ID"
  value       = var.enable_ecs ? aws_security_group.ecs[0].id : null
}

output "rds_security_group_id" {
  description = "RDS security group ID"
  value       = var.enable_rds ? aws_security_group.rds[0].id : null
}

output "redis_security_group_id" {
  description = "Redis security group ID"
  value       = var.enable_elasticache ? aws_security_group.redis[0].id : null
}

# ============================================================================
# ECS OUTPUTS (when enable_ecs = true)
# ============================================================================
output "ecs_cluster_name" {
  description = "ECS cluster name"
  value       = var.enable_ecs ? aws_ecs_cluster.main[0].name : null
}

output "ecs_service_name" {
  description = "ECS service name"
  value       = var.enable_ecs ? aws_ecs_service.backend[0].name : null
}

output "ecr_repository_url" {
  description = "ECR repository URL for backend Docker image"
  value       = var.enable_ecs ? aws_ecr_repository.backend[0].repository_url : null
}

output "ecs_task_definition_arn" {
  description = "ECS task definition ARN"
  value       = var.enable_ecs ? aws_ecs_task_definition.backend[0].arn : null
}

# ============================================================================
# BACKEND ENVIRONMENT VARIABLES
# ============================================================================
output "backend_env_vars" {
  description = "Environment variables needed by backend (only when RDS/Redis enabled)"
  value = {
    DATABASE_URL  = var.enable_rds ? "postgresql://${var.db_username}:${var.db_password}@${aws_rds_cluster.main[0].endpoint}:${aws_rds_cluster.main[0].port}/${aws_rds_cluster.main[0].database_name}" : null
    REDIS_URL     = var.enable_elasticache ? "redis://:${var.redis_auth_token}@${aws_elasticache_replication_group.main[0].primary_endpoint_address}:${aws_elasticache_replication_group.main[0].port}" : null
    S3_BUCKET     = aws_s3_bucket.audio_storage.id
    AWS_REGION    = var.aws_region
  }
  sensitive = true
}

# ============================================================================
# COST ESTIMATION (informational)
# ============================================================================
output "estimated_monthly_cost" {
  description = "Rough monthly cost estimate based on enabled resources"
  value = (
    (var.enable_ecs && var.ecs_desired_count > 0 ? 30 : 0) +
    (var.enable_rds ? 100 : 0) +
    (var.enable_elasticache ? 5 : 0) +
    (var.enable_alb ? 16 : 0) +
    2  # S3 base
  )
}

output "deployment_status" {
  description = "Current deployment status"
  value = {
    ecs_enabled          = var.enable_ecs
    ecs_tasks_running    = var.ecs_desired_count
    rds_enabled          = var.enable_rds
    elasticache_enabled  = var.enable_elasticache
    alb_enabled          = var.enable_alb
    message              = "Adjust feature toggles in terraform.tfvars to enable/disable subsystems"
  }
}
