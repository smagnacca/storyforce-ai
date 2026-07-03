# StoryForce.AI — Quick Start Deploy Guide

**Time to deploy:** ~15 minutes  
**Prerequisites:** GitHub account, AWS account, API keys

---

## Step 1: Push to GitHub (5 min)

From your Mac Terminal:

```bash
cd "/Users/scottmagnacca/Documents/Claude/Projects/Sandbox folder to experiment with/StoryForce.AI"

# Initialize git (if not already)
git init
git remote add origin https://github.com/smagnacca/storyforce-ai.git

# Add all generated code
git add -A

# Create initial commit
git commit -m "Initial: 32 files - backend, iOS, DevOps, infrastructure-as-code"

# Push to main branch
git push -u origin main
```

**Expected:** GitHub repository now contains all code.

---

## Step 2: Configure GitHub Secrets (5 min)

In GitHub repo Settings → Secrets and variables → Actions, add:

```
AWS_ACCOUNT_ID          → Your AWS account ID (12 digits)
AWS_REGION              → us-east-1 (or your preferred)
FABLE_API_KEY           → Your Claude Fable API key
GOOGLE_API_KEY          → Your Google Gemini API key
```

---

## Step 3: Deploy Infrastructure to AWS (3 min)

```bash
cd terraform

# Set environment variables
export AWS_ACCESS_KEY_ID=your-access-key
export AWS_SECRET_ACCESS_KEY=your-secret-key
export AWS_REGION=us-east-1

# Create terraform.tfvars (from example)
cp terraform.tfvars.example terraform.tfvars

# Edit with your values:
# - db_password (min 20 chars)
# - redis_auth_token (min 32 chars)

# Plan infrastructure
terraform plan -var-file=terraform.tfvars

# Apply (creates RDS, Redis, S3, VPC)
terraform apply -var-file=terraform.tfvars

# Save outputs
terraform output > infrastructure.json
```

**Expected:** AWS resources created in ~10 minutes (first time).

---

## Step 4: Configure Backend Environment

Create `.env` from template:

```bash
cd code/backend
cp .env.example .env

# Edit .env with values from terraform outputs:
DATABASE_URL=postgresql://storyforce_admin:YOURPASSWORD@RDS_ENDPOINT:5432/storyforce
REDIS_URL=redis://:AUTH_TOKEN@REDIS_ENDPOINT:6379
AWS_S3_BUCKET=storyforce-audio-YOUR_ACCOUNT_ID
```

---

## Step 5: Deploy Backend to AWS

Push will trigger GitHub Actions:

```bash
git add .env  # (or keep in secrets)
git push origin main

# GitHub Actions will:
# 1. Run tests (npm test)
# 2. Build Docker image
# 3. Push to AWS ECR
# 4. Deploy to staging
# 5. Run health checks
# 6. Deploy to production (with approval)
```

Monitor at: https://github.com/smagnacca/storyforce-ai/actions

---

## Step 6: Deploy iOS App

```bash
cd code/ios/StoryForce

# Update API endpoint in App.swift
# Change: let API_BASE_URL = "http://localhost:3000"
# To: let API_BASE_URL = "https://api.storyforce.ai"

# Open in Xcode
xcode StoryForce.xcworkspace

# Select target device (iPhone 15 Pro)
# Product → Archive → Distribute App
```

---

## Verification Checklist

- [ ] GitHub repo created with all 32 files
- [ ] AWS infrastructure deployed (check CloudFormation stack)
- [ ] RDS PostgreSQL database running
- [ ] ElastiCache Redis cluster operational
- [ ] S3 bucket created with encryption enabled
- [ ] Backend API responding at /health
- [ ] GitHub Actions pipeline passing
- [ ] iOS app building without errors
- [ ] TestFlight app uploaded (for App Store submission)

---

## Troubleshooting

### Git Push Fails
```bash
# If VM lock still blocking:
rm -f .git/index.lock .git/HEAD.lock
git push origin main
```

### RDS Connection Fails
```bash
# Verify security groups allow inbound traffic on port 5432
aws ec2 describe-security-groups --filters "Name=tag:Name,Values=storyforce-rds-sg"

# Check RDS status
aws rds describe-db-clusters --db-cluster-identifier storyforce-cluster
```

### Docker Build Fails
```bash
# Check Node version
node --version  # Should be 18+

# Rebuild without cache
docker build --no-cache -t storyforce-backend:latest .
```

### iOS App Build Fails
```bash
# Clean Xcode
Cmd+Shift+K

# Clear derived data
rm -rf ~/Library/Developer/Xcode/DerivedData/*

# Rebuild
Cmd+B
```

---

## What's Running

After deployment, you have:

- **Backend API** running on AWS Fargate
  - POST /api/auth/signup
  - POST /api/auth/login
  - POST /api/stories/generate (Fable LLM)
  - POST /api/stories/:id/practice (Gemini Voice)
  - GET /api/analytics/summary

- **iOS App** in TestFlight
  - Auth screens (sign in/sign up)
  - Story generation
  - Practice coaching
  - Analytics dashboard
  - Client profile management

- **Infrastructure**
  - RDS Aurora PostgreSQL (2 instances)
  - ElastiCache Redis (2 nodes)
  - S3 bucket for audio files
  - VPC with public/private subnets
  - Security groups for isolation

---

## Next: Hours 11-24

1. **Fable LLM Integration**
   - Refine story generation prompt
   - Test edge cases
   - Cost monitoring

2. **Gemini Voice API**
   - Wire up transcription
   - Implement scoring algorithm
   - Test latency

3. **End-to-End Testing**
   - Auth flow
   - Story generation
   - Practice coaching
   - Analytics tracking

---

## Support

- **Terraform Issues:** Check `terraform.log` for errors
- **GitHub Actions:** Check "Actions" tab for workflow logs
- **AWS Console:** https://console.aws.amazon.com
- **Xcode Build:** Check Build Log (⌘+Shift+K clears cache)

---

**Estimated total time:** 30-45 minutes  
**Cost:** ~$2-5/day for staging (RDS t4g.small + Redis cache.t4g.micro)  
**Next check-in:** When iOS app first runs against live API
