# AWS Deployment Guide — Phase 3

**Status:** Ready to deploy  
**Estimated time:** 20-30 minutes  
**Infrastructure cost:** ~$150-200/month (production)  

---

## Pre-Deployment Checklist

- [ ] AWS account created and configured
- [ ] AWS CLI installed and authenticated (`aws configure`)
- [ ] Terraform installed (v1.0+)
- [ ] GitHub Secrets configured for CI/CD
- [ ] Environment variables prepared

---

## Step 1: Prepare AWS Account

```bash
# Set variables
export AWS_ACCOUNT_ID="YOUR_ACCOUNT_ID"
export AWS_REGION="us-east-1"

# Create S3 bucket for Terraform state
aws s3api create-bucket \
  --bucket storyforce-terraform-state \
  --region $AWS_REGION

# Enable versioning on state bucket
aws s3api put-bucket-versioning \
  --bucket storyforce-terraform-state \
  --versioning-configuration Status=Enabled

# Create DynamoDB table for state locking
aws dynamodb create-table \
  --table-name terraform-locks \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5 \
  --region $AWS_REGION

echo "✅ AWS account prepared"
```

---

## Step 2: Create Infrastructure Variables

```bash
cd terraform

# Copy and edit variables
cp terraform.tfvars.example terraform.tfvars

# Edit terraform.tfvars with your values:
# - db_password (min 20 chars)
# - redis_auth_token (min 32 chars)
# - aws_region
# - environment (production or staging)
```

---

## Step 3: Deploy Infrastructure

```bash
# Initialize Terraform (one time)
terraform init

# Review planned infrastructure
terraform plan -var-file=terraform.tfvars

# Deploy (takes 10-15 minutes)
terraform apply -var-file=terraform.tfvars

# Save outputs
terraform output > infrastructure.json

echo "✅ Infrastructure deployed"
```

---

## Step 4: Configure Application Environment

```bash
# Extract credentials from Terraform outputs
export RDS_ENDPOINT=$(terraform output -raw rds_cluster_endpoint)
export REDIS_ENDPOINT=$(terraform output -raw redis_primary_endpoint)
export S3_BUCKET=$(terraform output -raw s3_bucket_name)

# Create .env.production from outputs
cat > ../code/backend/.env.production << EOF
NODE_ENV=production
PORT=3000
DATABASE_URL=postgresql://storyforce_admin:YOUR_PASSWORD@$RDS_ENDPOINT:5432/storyforce
REDIS_URL=redis://:YOUR_AUTH_TOKEN@$REDIS_ENDPOINT:6379
AWS_REGION=$AWS_REGION
AWS_S3_BUCKET=$S3_BUCKET
FABLE_API_KEY=$FABLE_API_KEY
GOOGLE_API_KEY=$GOOGLE_API_KEY
JWT_SECRET=$JWT_SECRET
LLM_BUDGET_LIMIT=1500
EOF

echo "✅ Environment configured"
```

---

## Step 5: Configure GitHub Secrets

Add these to GitHub repo → Settings → Secrets:

```
AWS_ACCOUNT_ID          → Your AWS account ID
AWS_REGION              → us-east-1
FABLE_API_KEY          → Your Claude Fable API key
GOOGLE_API_KEY         → Your Google Gemini API key
JWT_SECRET             → Random 32+ char string
DB_PASSWORD            → From terraform.tfvars
REDIS_AUTH_TOKEN       → From terraform.tfvars
```

---

## Step 6: Deploy Backend to Fargate

```bash
# Trigger GitHub Actions CI/CD
git push origin main

# Or manually deploy:
cd ../code/backend

# Build Docker image
docker build -t storyforce-backend:latest .

# Push to AWS ECR
aws ecr get-login-password --region us-east-1 | \
  docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com

docker tag storyforce-backend:latest \
  $AWS_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/storyforce-backend:latest

docker push $AWS_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/storyforce-backend:latest

echo "✅ Backend deployed to ECR"
```

---

## Step 7: Initialize Database

```bash
# Connect to RDS
psql -h $RDS_ENDPOINT -U storyforce_admin -d storyforce

# Run migrations
\i code/backend/migrations/001_initial_schema.sql

# Verify tables
\dt

echo "✅ Database initialized"
```

---

## Step 8: Verify Deployment

```bash
# Check RDS connectivity
aws rds describe-db-clusters \
  --db-cluster-identifier storyforce-cluster \
  --region us-east-1

# Check Redis connectivity
redis-cli -h $REDIS_ENDPOINT -a $REDIS_AUTH_TOKEN ping

# Check S3 bucket
aws s3 ls s3://$S3_BUCKET

# Test backend health
curl https://api.storyforce.ai/health

echo "✅ All systems healthy"
```

---

## Post-Deployment

### Monitor Infrastructure

```bash
# Watch CloudWatch logs
aws logs tail /aws/ecs/storyforce --follow

# Monitor costs
aws ce get-cost-and-usage \
  --time-period Start=2026-07-01,End=2026-07-31 \
  --granularity MONTHLY \
  --metrics BlendedCost
```

### Scaling

```bash
# Update desired count in ECS service
aws ecs update-service \
  --cluster storyforce-production \
  --service storyforce-backend \
  --desired-count 3  # Scale to 3 instances

# Enable autoscaling
aws application-autoscaling register-scalable-target \
  --service-namespace ecs \
  --resource-id service/storyforce-production/storyforce-backend \
  --scalable-dimension ecs:service:DesiredCount \
  --min-capacity 2 \
  --max-capacity 10
```

---

## Cleanup (Development Only)

```bash
# Destroy all infrastructure
terraform destroy -var-file=terraform.tfvars

# Delete S3 state bucket
aws s3 rb s3://storyforce-terraform-state --force

# Delete DynamoDB table
aws dynamodb delete-table --table-name terraform-locks
```

---

## Troubleshooting

### Database Connection Fails

```bash
# Check security group
aws ec2 describe-security-groups \
  --filters Name=tag:Name,Values=storyforce-rds-sg

# Verify inbound rules allow port 5432 from ECS
aws ec2 authorize-security-group-ingress \
  --group-id sg-xxxxxx \
  --protocol tcp \
  --port 5432 \
  --source-group sg-yyyyyy  # ECS security group
```

### Redis Connection Fails

```bash
# Check cluster status
aws elasticache describe-cache-clusters \
  --cache-cluster-id storyforce-cache

# Verify auth token
aws elasticache describe-cache-clusters \
  --cache-cluster-id storyforce-cache \
  --show-cache-node-info
```

### High Costs

```bash
# Downsize RDS instance (staging only)
terraform apply -var db_instance_class=db.t4g.micro

# Reduce Redis nodes (staging only)
terraform apply -var redis_num_nodes=1
```

---

## Cost Breakdown (Production)

| Service | Instance | Count | Monthly |
|---------|----------|-------|---------|
| RDS Aurora | t4g.small | 2 | $95 |
| ElastiCache Redis | t4g.micro | 2 | $30 |
| S3 + Data Transfer | — | — | $15 |
| ECS Fargate | 0.25 vCPU | 2-10 | $40-80 |
| **TOTAL** | — | — | **$150-220** |

---

## Next Steps

1. ✅ Infrastructure deployed
2. ⏳ Configure CI/CD secrets
3. ⏳ Deploy backend container
4. ⏳ Run E2E tests against production
5. ⏳ Enable monitoring & alerts

**Deployment time:** ~30 minutes  
**Go-live:** Ready for July 31 launch! 🚀
