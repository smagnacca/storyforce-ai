variable "aws_region" {
  description = "AWS region for deployment"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name (dev, staging, production)"
  type        = string
  default     = "production"

  validation {
    condition     = contains(["dev", "staging", "production"], var.environment)
    error_message = "Environment must be dev, staging, or production."
  }
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "storyforce"
}

# ============================================================================
# VPC AND NETWORKING
# ============================================================================
variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.11.0/24"]
}

# ============================================================================
# DATABASE
# ============================================================================
variable "db_name" {
  description = "Database name"
  type        = string
  default     = "storyforce"
  sensitive   = true
}

variable "db_username" {
  description = "Database master username"
  type        = string
  default     = "storyforce_admin"
  sensitive   = true
}

variable "db_password" {
  description = "Database master password"
  type        = string
  sensitive   = true

  validation {
    condition     = length(var.db_password) >= 20
    error_message = "Database password must be at least 20 characters."
  }
}

variable "db_instance_class" {
  description = "RDS instance type"
  type        = string
  default     = "db.r6g.large"
}

variable "db_instance_count" {
  description = "Number of RDS instances in the cluster"
  type        = number
  default     = 2

  validation {
    condition     = var.db_instance_count >= 1 && var.db_instance_count <= 5
    error_message = "Instance count must be between 1 and 5."
  }
}

# ============================================================================
# ELASTICACHE REDIS
# ============================================================================
variable "redis_cluster_id" {
  description = "Redis cluster identifier"
  type        = string
  default     = "storyforce-cache"
}

variable "redis_node_type" {
  description = "Redis node type"
  type        = string
  default     = "cache.t3.micro"
}

variable "redis_num_nodes" {
  description = "Number of Redis nodes"
  type        = number
  default     = 2

  validation {
    condition     = var.redis_num_nodes >= 1 && var.redis_num_nodes <= 500
    error_message = "Number of nodes must be between 1 and 500."
  }
}

variable "redis_auth_token" {
  description = "Redis AUTH token for authentication"
  type        = string
  sensitive   = true

  validation {
    condition     = length(var.redis_auth_token) >= 32
    error_message = "Redis auth token must be at least 32 characters."
  }
}

# ============================================================================
# TAGS
# ============================================================================
variable "additional_tags" {
  description = "Additional tags to apply to resources"
  type        = map(string)
  default     = {}
}
