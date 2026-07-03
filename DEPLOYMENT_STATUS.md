# StoryForce.AI — Deployment Status & Next Steps

**Last Updated:** 2026-07-03  
**Status:** ✅ Infrastructure ready for testing  
**Current Cost:** $2/month (S3 only)

---

## What's Been Done

### ✅ Infrastructure Provisioned (22 AWS Resources)

**VPC & Networking**
- VPC: `vpc-0405abea9459e41be` (10.0.0.0/16)
- 2 public subnets (for ECS tasks with public IPs)
- 2 private subnets (reserved for RDS/cache when enabled)
- Internet Gateway + route tables configured
- All security groups configured and ready

**ECS Fargate (Ready to Run)**
- Cluster: `storyforce-cluster`
- Task Definition: `storyforce-backend:1` (256 CPU / 512 MB RAM)
- Service: `storyforce-backend-service` (0 desired tasks = $0 cost)
- IAM role + ECR access policies configured
- CloudWatch logs group: `/ecs/storyforce` (7-day retention)

**Container Registry (Ready for Docker Image)**
- ECR Repository: `199584041806.dkr.ecr.us-east-1.amazonaws.com/storyforce-backend`
- Image scanning enabled
- Dockerfile created: `code/backend/Dockerfile` (Node.js 18 Alpine)

**Storage**
- S3 bucket: `storyforce-audio-199584041806`
- Versioning enabled
- Encryption enabled (AES-256)
- Public access blocked

**Code Ready But Disabled (Zero Cost)**
- RDS Aurora PostgreSQL 15.17 infrastructure code (activate with `enable_rds = true`)
- ElastiCache Redis infrastructure code (activate with `enable_elasticache = true`)
- Application Load Balancer code (activate with `enable_alb = true`)

---

## How It Works — Progressive Enablement

All infrastructure is controlled by **terraform variables** in `terraform/terraform.tfvars`:

```hcl
# Phase 1: ECS only (ACTIVE NOW)
enable_ecs          = true
ecs_desired_count   = 0        # 0 = disabled ($0), 1+ = running
enable_rds          = false
enable_elasticache  = false
enable_alb          = false
```

**To advance to Phase 2 (add database):**
```bash
cd terraform
# Edit terraform.tfvars: set enable_rds = true
terraform apply
```

**To start running ECS tasks (Phase 1.5):**
```bash
terraform apply -var="ecs_desired_count=1"
```

---

## Cost Breakdown

| Phase | Resources | Monthly Cost | Status |
|---|---|---|---|
| **Phase 1** | ECS (0 tasks) + S3 + VPC | $2 | ✅ ACTIVE |
| **Phase 2** | + RDS Aurora (2 × db.r6g.large) | +$100 | ⏳ Ready |
| **Phase 3** | + ElastiCache Redis (2 × cache.t3.micro) | +$5 | ⏳ Ready |
| **Phase 4** | + ALB | +$16 | ⏳ Ready |
| **ALL ENABLED** | Full production stack | ~$123/month | ⏳ |

**Key:** You only pay for what's enabled. With ECS desired_count=0, you pay $0 for compute.

---

## Next Steps — Immediate (Phase 1.5)

### 1. Build & Push Docker Image
```bash
cd code/backend

# Build image
docker build -t storyforce-backend:latest .

# Get ECR login token
aws ecr get-login-password --region us-east-1 | \
  docker login --username AWS --password-stdin \
  199584041806.dkr.ecr.us-east-1.amazonaws.com

# Tag & push
docker tag storyforce-backend:latest \
  199584041806.dkr.ecr.us-east-1.amazonaws.com/storyforce-backend:latest

docker push \
  199584041806.dkr.ecr.us-east-1.amazonaws.com/storyforce-backend:latest
```

### 2. Scale ECS to 1 Task (Start Running Backend)
```bash
cd ../terraform
terraform apply -var="ecs_desired_count=1"
```

### 3. Get Task Public IP & Test
```bash
# In AWS ECS console: 
# - Click Cluster → storyforce-cluster
# - Click Service → storyforce-backend-service
# - Click Tasks
# - Note the task's "Public IP"

# Test API health
curl http://<PUBLIC_IP>:3000/api/health
```

---

## Next Steps — Phase 2 (When Ready for Database)

### 1. Enable RDS in Terraform
```bash
cd terraform

# Edit terraform.tfvars: set enable_rds = true
terraform apply
```
This will provision:
- RDS Aurora PostgreSQL 15.17 cluster
- 2 db.r6g.large instances (multi-AZ)
- Database subnet group + security group

### 2. Update ECS Task with Database URL
Get the RDS endpoint from terraform output:
```bash
terraform output backend_env_vars
```

Update `code/backend/src/server.js` to read from `process.env.DATABASE_URL` (it may already do this).

Push a new Docker image with any changes:
```bash
cd ../code/backend
docker build -t storyforce-backend:v2 .
docker push 199584041806.dkr.ecr.us-east-1.amazonaws.com/storyforce-backend:v2
```

Update ECS task definition in AWS console to use the new image URL.

### 3. Run Database Migrations
```bash
cd code/backend
npm run migrate
```

---

## Next Steps — Phase 3 (When Ready for Caching)

### 1. Enable ElastiCache in Terraform
```bash
cd terraform

# Edit terraform.tfvars: set enable_elasticache = true
terraform apply
```

This will provision:
- Redis 7.0 replication group
- 2 cache.t3.micro nodes
- Cache subnet group + security group
- Auth token configured

### 2. Update Backend Environment
Get Redis URL from terraform output and add to ECS task definition.

Code should read from `process.env.REDIS_URL` and connect automatically.

---

## Next Steps — Phase 4 (Production Load Balancing)

### 1. Enable ALB in Terraform
```bash
cd terraform

# Edit terraform.tfvars: set enable_alb = true
terraform apply
```

This will provision:
- Application Load Balancer
- Target group
- HTTP/HTTPS listeners (configure HTTPS later)

### 2. Register Domain + ACM Certificate
- Buy domain via Route 53 or registrar (~$12/year)
- Request ACM certificate (free with AWS)
- Point domain to ALB

### 3. Scale ECS to 2+ Tasks
```bash
terraform apply -var="ecs_desired_count=2"
```

ALB will automatically distribute traffic across tasks.

---

## Important Files

| File | Purpose | Status |
|---|---|---|
| `terraform/main.tf` | Infrastructure code (22 resources, conditional) | ✅ Ready |
| `terraform/variables.tf` | Feature toggles + configuration | ✅ Ready |
| `terraform/terraform.tfvars` | Phase configuration (edit to advance) | ✅ Ready |
| `terraform/outputs.tf` | Outputs for endpoints/IDs | ✅ Ready |
| `code/backend/Dockerfile` | Node.js container definition | ✅ Ready |
| `code/backend/src/server.js` | Express server code | ✅ Ready |
| `code/backend/.env` | Local dev environment (gitignored) | ⚠️ Add production secrets |
| `code/ios/App.swift` | iOS app entry point | ⚠️ Update `apiBaseURL` when backend is live |

---

## Safety Checklist

- ✅ No hardcoded credentials in terraform files
- ✅ AWS Secrets Manager support built in (not used yet, ready when needed)
- ✅ All infrastructure code preserved (RDS/cache not deleted, just disabled)
- ✅ S3 encryption enabled
- ✅ Public access to S3 blocked
- ✅ Budget alert: $20 threshold on AWS account
- ✅ CloudWatch logs configured for audit trail

---

## Troubleshooting

**"ECS task won't start"**
- Check CloudWatch logs: `/ecs/storyforce`
- Verify Docker image exists in ECR and is correct
- Check ECS task definition environment variables

**"Can't connect to RDS from ECS"**
- Verify `enable_rds = true` in terraform.tfvars
- Check security group allows port 5432 from ECS SG to RDS SG
- Verify DATABASE_URL environment variable is set correctly in ECS task definition

**"Docker push to ECR fails"**
- Verify IAM user has ecr:* permissions
- Get fresh ECR login token: `aws ecr get-login-password ...`
- Check image name matches ECR repository URL

---

## Questions or Issues?

Refer to memory files:
- `ecs_simplified_deployment_2026_07_03.md` — Architecture & patterns
- `terraform_test_cycle_final.md` — AWS compatibility notes
- CHANGELOG.md — Historical session summaries

---

**Next Review Date:** After Phase 1.5 completes (ECS task running with test data)
