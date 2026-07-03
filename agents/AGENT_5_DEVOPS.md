# AGENT #5 — DevOps & Infrastructure Specialist

**Role:** Infrastructure provisioning, deployment automation, environment setup  
**Mode:** Fully autonomous, no human decisions needed  
**Timeline:** Week 1 focus (infrastructure), Week 4-5 deployment  
**Success Criteria:** Infrastructure ready, CI/CD pipeline working, deployment automated

---

## Your Mission (Week 1: Priority #1)

Get infrastructure ready so Agents #1-4 can deploy their code immediately.

```
NO INFRASTRUCTURE = OTHER AGENTS CAN'T DEPLOY CODE
YOUR WORK IS BLOCKING CRITICAL PATH
PRIORITY: GET THIS DONE FIRST
```

---

## Tasks (In Order)

### Task 1: AWS Account & Setup (30 min)
```
Action: Prepare AWS environment
├─ AWS account ready (assume Scott has one)
├─ IAM user created with appropriate permissions
├─ AWS CLI installed and configured locally
├─ Terraform installed locally
└─ Cost: $0
```

### Task 2: PostgreSQL Database (RDS) — 20 min
```
Target: Production-ready PostgreSQL for app data

Action:
1. Create RDS PostgreSQL instance
   ├─ Engine: PostgreSQL 14
   ├─ Instance class: db.t3.micro (dev)
   ├─ Storage: 20GB (starts small, scales)
   ├─ Backup: 7-day retention
   ├─ Multi-AZ: No (dev only)
   └─ Public access: No (private VPC)

2. Create database "storyforce_production"

3. Create database user with password

4. Test connection from local machine

Output:
├─ RDS endpoint: [endpoint].rds.amazonaws.com
├─ Database: storyforce_production
├─ Username: storyforce_user
├─ Password: [secure, store in .env]
└─ Connection string: postgresql://user:pass@endpoint/storyforce_production

Cost: ~$10-15/month (free tier eligible for dev)
```

### Task 3: Redis Cache (ElastiCache) — 15 min
```
Target: In-memory caching for sessions, rate limiting

Action:
1. Create ElastiCache Redis cluster
   ├─ Engine: Redis 7.0
   ├─ Node type: cache.t3.micro (dev)
   ├─ Nodes: 1 (dev only)
   ├─ Parameter group: default
   └─ Encryption: Enabled

2. Create subnet group for Redis

3. Configure security group to allow backend access

Output:
├─ Redis endpoint: [endpoint].cache.amazonaws.com:6379
├─ Connection string: redis://endpoint:6379
└─ Cost: ~$10-15/month

Note: Week 4+ may upgrade to Multi-AZ for production
```

### Task 4: S3 Audio Storage Bucket — 15 min
```
Target: Secure storage for voice recordings

Action:
1. Create S3 bucket: "storyforce-audio-[uuid]"
   ├─ Region: us-east-1 (or your region)
   ├─ Block public access: YES (private bucket)
   ├─ Versioning: Disabled
   ├─ Encryption: AES-256 (default)
   └─ Server-side encryption: Enabled

2. Create lifecycle policy (90-day auto-delete)
   ├─ Rule: Delete objects after 90 days
   ├─ Status: Enabled
   └─ Rationale: GDPR/CCPA compliance

3. Create IAM policy for bucket access
   ├─ Allow backend service to read/write
   ├─ Deny public access
   └─ Log all access

4. Create S3 access key for backend service

Output:
├─ Bucket name: storyforce-audio-[uuid]
├─ Region: us-east-1
├─ Access key: [key]
├─ Secret key: [secret]
└─ Cost: ~$2-5/month (dev usage)
```

### Task 5: VPC & Networking — 15 min
```
Target: Secure network isolation

Action:
1. Create VPC (if not using default)
   ├─ CIDR: 10.0.0.0/16
   ├─ Subnets: 2 public, 2 private
   ├─ NAT gateway: For private subnet outbound
   └─ Route tables: Configured

2. Create security groups
   ├─ Backend security group
   │  ├─ Inbound: Allow from ALB on port 3000
   │  ├─ Outbound: Allow all (for external APIs)
   │  └─ RDS access: Allow from backend to RDS
   │
   ├─ RDS security group
   │  ├─ Inbound: Allow from backend on port 5432
   │  └─ Outbound: None needed
   │
   └─ Redis security group
      ├─ Inbound: Allow from backend on port 6379
      └─ Outbound: None needed

3. Create application load balancer (ALB)
   ├─ Target: Backend service (port 3000)
   ├─ Health check: /health
   ├─ Sticky sessions: Disabled
   └─ HTTPS: Configure Week 4

Output: Network isolated, secure access paths
```

### Task 6: Docker Image — 30 min
```
Target: Containerized backend for deployment

Create file: code/backend/docker/Dockerfile

Content:
├─ Base image: node:18-alpine (small, fast)
├─ Working dir: /app
├─ Copy package.json, yarn.lock
├─ RUN yarn install --frozen-lockfile
├─ Copy source code
├─ EXPOSE 3000
├─ HEALTHCHECK: /health endpoint
├─ CMD: node src/server.js
└─ Cost: Build locally, push to ECR (AWS container registry)

Actions:
1. Build image locally: docker build -t storyforce:v1 .
2. Test locally: docker run -p 3000:3000 storyforce:v1
3. Create ECR repository: storyforce-backend
4. Push image: docker push [ecr-url]/storyforce-backend:v1
5. Verify image can start cleanly

Output: Docker image in ECR, ready for deployment
```

### Task 7: Terraform Infrastructure-as-Code — 30 min
```
Target: Reproducible infrastructure setup

Create files in: code/devops/terraform/

Files needed:
├─ main.tf (provider, overall config)
├─ vpc.tf (VPC, subnets, security groups)
├─ rds.tf (PostgreSQL database)
├─ redis.tf (ElastiCache Redis)
├─ s3.tf (Audio storage bucket)
├─ iam.tf (Service roles & policies)
├─ variables.tf (Input variables)
├─ outputs.tf (Output values: endpoints, etc.)
└─ terraform.tfvars (Local values, gitignored)

Terraform commands to run:
1. terraform init (initialize)
2. terraform plan (review changes)
3. terraform apply (create resources)
4. terraform output (print endpoints, IDs)

Benefits:
├─ Reproducible infrastructure
├─ Easy to scale up/down
├─ Easy to tear down (cleanup)
└─ Infrastructure as code (version control)

Cost: Free (Terraform)
```

### Task 8: CI/CD Pipeline Setup — 20 min
```
Target: Automated testing & deployment

Technology: GitHub Actions (free with GitHub repo)

Create file: code/devops/ci-cd/.github/workflows/deploy.yml

Pipeline stages:
1. Test
   ├─ npm test (backend unit tests)
   ├─ pytest (Python tests if any)
   └─ Check code coverage

2. Build
   ├─ docker build
   ├─ docker push to ECR
   └─ Generate image tag from commit hash

3. Deploy
   ├─ Update deployment manifest
   ├─ Deploy to staging first
   ├─ Run integration tests
   └─ Deploy to production if successful

4. Monitor
   ├─ Check application health
   ├─ Log deployment
   └─ Alert if deployment fails

Triggers:
├─ On push to main branch
├─ On PR creation (test only)
└─ Manual trigger available

Cost: Free (GitHub Actions free tier is generous)
```

---

## Your Weekly Timeline

### Week 1 (NOW): Foundation
- [ ] AWS account setup
- [ ] RDS PostgreSQL created
- [ ] Redis cache created
- [ ] S3 bucket created
- [ ] VPC & security groups configured
- [ ] Docker image built & tested
- [ ] Terraform code written & validated
- [ ] CI/CD pipeline scaffolded
- [ ] **Deliverable:** Infrastructure ready for deployment

### Week 2-3: Deployment to Staging
- [ ] Backend service deployed to staging
- [ ] Verify all services (RDS, Redis, S3) reachable from backend
- [ ] Health checks passing
- [ ] Monitoring & logging active

### Week 4: Production Preparation
- [ ] HTTPS certificates provisioned
- [ ] Production database backup policy
- [ ] Auto-scaling configuration
- [ ] Disaster recovery setup

### Week 5: Launch
- [ ] Final pre-launch checks
- [ ] Deployment to production
- [ ] Monitor for issues
- [ ] Ready for Babson event

---

## Configuration Files to Create

### .env.example (for backend to use)
```
# Database
DATABASE_URL=postgresql://user:pass@endpoint/storyforce_production

# Redis
REDIS_URL=redis://endpoint:6379

# S3
AWS_S3_BUCKET=storyforce-audio-[uuid]
AWS_REGION=us-east-1
AWS_ACCESS_KEY_ID=[key]
AWS_SECRET_ACCESS_KEY=[secret]

# Fable API
FABLE_API_KEY=[scott provides]

# Gemini API
GOOGLE_API_KEY=[scott provides]

# App
NODE_ENV=production
PORT=3000
```

---

## Testing Infrastructure (Before Agent #1 Uses It)

After everything is created, test:
```bash
# Test PostgreSQL
psql postgresql://user:pass@endpoint/storyforce_production -c "SELECT 1"

# Test Redis
redis-cli -h endpoint.cache.amazonaws.com ping

# Test S3
aws s3 ls s3://storyforce-audio-[uuid]

# Test Docker image
docker run -p 3000:3000 [ecr-url]/storyforce-backend:v1

# Verify health endpoint
curl http://localhost:3000/health
```

All tests must pass before signaling other agents to proceed.

---

## Success Criteria (Must All Pass)

✅ AWS account configured with proper IAM  
✅ PostgreSQL RDS running, database created, connection tested  
✅ Redis cache running, connection tested  
✅ S3 bucket created with lifecycle policy  
✅ VPC configured with security groups  
✅ Docker image builds & runs locally  
✅ Terraform code is valid & documented  
✅ CI/CD pipeline scaffolded & ready  
✅ All connection strings working  
✅ Documentation ready for other agents  

---

## Cost (Week 1)

```
RDS (micro): $10-15/month
Redis (micro): $10-15/month
S3 storage: $2-5/month
Data transfer: $0-5/month
Total: ~$35-45/month (minimal)

Free tier covers most of this first 12 months.
```

---

## What Happens If You Get Stuck

**Issue:** AWS permission denied  
**Fix:** Check IAM policy, create new user with correct permissions

**Issue:** Terraform apply fails  
**Fix:** Check variable values, AWS credentials, region

**Issue:** Docker build fails  
**Fix:** Check Node.js version, dependencies, Docker daemon running

**If truly blocked:** Create PR with error message, Scott helps debug

---

## Your Next Steps (Start NOW)

1. Read Technical Architecture spec (Section 8: Deployment)
2. Gather AWS credentials
3. Install: AWS CLI, Terraform, Docker
4. Start with Task 1: AWS setup
5. Work through tasks 1-8 in order
6. Test all connections
7. Create PR when complete
8. Signal Agents #1-4 that infrastructure is ready

---

**Timeline: Aim to complete by end of Day 1**  
**Cost: $0 (local work) + ~$35/month AWS**  
**Criticality: HIGHEST (other agents depend on you)**

Let's go! 🚀
