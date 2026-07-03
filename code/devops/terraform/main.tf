terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "StoryForce"
      Environment = var.environment
      ManagedBy   = "Terraform"
      CreatedAt   = timestamp()
    }
  }
}

# Enable AWS CloudTrail for audit logging
resource "aws_cloudtrail" "storyforce" {
  depends_on           = [aws_s3_bucket_policy.cloudtrail]
  name                 = "storyforce-cloudtrail"
  s3_bucket_name       = aws_s3_bucket.cloudtrail_logs.id
  include_global_events = true
  is_multi_region_trail = true
  enable_log_file_validation = true
  is_organization_trail = false
}

resource "aws_s3_bucket" "cloudtrail_logs" {
  bucket = "storyforce-cloudtrail-logs-${data.aws_caller_identity.current.account_id}"
}

resource "aws_s3_bucket_policy" "cloudtrail" {
  bucket = aws_s3_bucket.cloudtrail_logs.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid    = "AWSCloudTrailAclCheck"
      Effect = "Allow"
      Principal = {
        Service = "cloudtrail.amazonaws.com"
      }
      Action   = "s3:GetBucketAcl"
      Resource = aws_s3_bucket.cloudtrail_logs.arn
    }]
  })
}

# Data source for current AWS account
data "aws_caller_identity" "current" {}

# VPC Configuration
module "vpc" {
  source = "./vpc"

  project_name  = var.project_name
  environment   = var.environment
  aws_region    = var.aws_region
  vpc_cidr      = var.vpc_cidr
  public_subnets = var.public_subnets
  private_subnets = var.private_subnets

  tags = local.common_tags
}

# RDS PostgreSQL Configuration
module "rds" {
  source = "./rds"

  project_name        = var.project_name
  environment         = var.environment
  instance_class      = var.rds_instance_class
  allocated_storage   = var.rds_allocated_storage
  database_name       = var.database_name
  database_user       = var.database_user
  database_password   = var.database_password
  vpc_security_group_id = module.vpc.rds_security_group_id
  db_subnet_group_name  = module.vpc.db_subnet_group_name

  tags = local.common_tags

  depends_on = [module.vpc]
}

# Redis Cache Configuration
module "redis" {
  source = "./redis"

  project_name        = var.project_name
  environment         = var.environment
  node_type           = var.redis_node_type
  num_cache_nodes     = var.redis_num_nodes
  parameter_group_name = var.redis_parameter_group
  security_group_id   = module.vpc.redis_security_group_id
  subnet_group_name   = module.vpc.cache_subnet_group_name

  tags = local.common_tags

  depends_on = [module.vpc]
}

# S3 Audio Storage Configuration
module "s3_audio" {
  source = "./s3"

  project_name = var.project_name
  environment  = var.environment
  bucket_name  = "storyforce-audio-${data.aws_caller_identity.current.account_id}"

  # Lifecycle policy: delete recordings after 90 days (GDPR/CCPA compliant)
  lifecycle_days = 90

  tags = local.common_tags
}

# IAM Roles for Services
module "iam" {
  source = "./iam"

  project_name         = var.project_name
  environment          = var.environment
  s3_bucket_arn        = module.s3_audio.bucket_arn
  rds_endpoint         = module.rds.endpoint
  redis_endpoint       = module.redis.endpoint

  tags = local.common_tags
}

# Local tags for all resources
locals {
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}
