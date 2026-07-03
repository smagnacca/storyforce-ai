# Terraform Backend Configuration
# Stores state in S3 with DynamoDB locking for team collaboration

terraform {
  backend "s3" {
    bucket         = "storyforce-terraform-state"
    key            = "prod/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-locks"
  }
}

# Run this first to initialize backend:
# aws s3api create-bucket --bucket storyforce-terraform-state --region us-east-1
# aws dynamodb create-table \
#   --table-name terraform-locks \
#   --attribute-definitions AttributeName=LockID,AttributeType=S \
#   --key-schema AttributeName=LockID,KeyType=HASH \
#   --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5 \
#   --region us-east-1
