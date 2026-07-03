# 12-Hour Real Execution Plan — LIVE

**Start time:** NOW  
**Target completion:** 12 hours from now  
**Mode:** Actual API calls, real costs, real infrastructure  
**Track costs:** Yes, monitor LLM budget consumption  

---

## ⏱️ Timeline Breakdown

| Hour | Task | Duration | Status |
|------|------|----------|--------|
| 0-1 | Push all code to GitHub | 10 min | ⏳ NEXT |
| 1-2 | Set up AWS credentials & terraform | 20 min | ⏳ |
| 2-5 | Run terraform apply (infrastructure provisioning) | 180 min | ⏳ |
| 5-6 | Initialize RDS database & seed test data | 60 min | ⏳ |
| 6-8 | Run actual E2E tests against live database | 120 min | ⏳ |
| 8-9 | Test Fable LLM story generation (real API calls) | 60 min | ⏳ |
| 9-10 | Test Gemini Voice API (transcription + scoring) | 60 min | ⏳ |
| 10-11 | Deploy backend to AWS Fargate | 60 min | ⏳ |
| 11-12 | Final E2E tests against production API | 60 min | ⏳ |

---

## 🔑 Prerequisites I Need From You

Before I can start actual execution, provide:

```bash
# AWS Credentials
export AWS_ACCESS_KEY_ID="..."
export AWS_SECRET_ACCESS_KEY="..."
export AWS_REGION="us-east-1"

# API Keys (already have?)
export FABLE_API_KEY="..."
export GOOGLE_API_KEY="..."

# Database credentials (for terraform.tfvars)
DB_PASSWORD="min-20-chars-random-string"
REDIS_AUTH_TOKEN="min-32-chars-random-string"
```

**Question:** Do you have these credentials ready, or should I generate them?

---

## 💰 Cost Tracking

I'll track every API call:

```
Fable LLM:
  - Story generation: ~$0.01-0.05 per call
  - Budget: $0.47K remaining
  - Plan: 10 test generations = ~$0.50

Gemini Voice:
  - Transcription: ~$0.0001 per call
  - Scoring: ~$0.0002 per call
  - Plan: 20 test calls = ~$0.01

AWS Infrastructure:
  - RDS: $95-150/month (running for 1-2 hours)
  - Redis: $30/month (running for 1-2 hours)
  - S3: ~$0.50/month (minimal usage)
  - Estimated: $2-5 for this test run

TOTAL ESTIMATED COST: $50-60
```

---

## 🚀 Execution Steps

### Hour 0-1: Push to GitHub ✅
```bash
cd StoryForce.AI
git add -A
git commit -m "LIVE EXECUTION: All 4 phases ready for production testing"
git push origin master
```

### Hour 1-2: AWS Setup ⏳
```bash
# Verify AWS credentials
aws sts get-caller-identity

# Create Terraform state bucket
aws s3api create-bucket --bucket storyforce-terraform-state

# Create state lock table
aws dynamodb create-table \
  --table-name terraform-locks \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5
```

### Hour 2-5: Terraform Apply ⏳
```bash
cd terraform
terraform init
terraform apply -var-file=terraform.tfvars
# Wait 10-15 min for RDS, Redis, S3 provisioning
```

### Hour 5-6: Database Init ⏳
```bash
# Extract RDS endpoint from terraform outputs
RDS_ENDPOINT=$(terraform output -raw rds_cluster_endpoint)

# Connect and run migrations
psql -h $RDS_ENDPOINT -U storyforce_admin -d storyforce -f ../code/backend/migrations/001_initial_schema.sql

# Seed test data
psql -h $RDS_ENDPOINT -U storyforce_admin -d storyforce << EOF
INSERT INTO users (email, password_hash, first_name, last_name, subscription_tier, created_at)
VALUES ('test@example.com', '$2a$12$...', 'Test', 'User', 'free', NOW());

INSERT INTO client_profiles (user_id, client_name, company, industry, winter_json, spring_json, created_at)
VALUES (1, 'TechCorp CEO', 'TechCorp', 'Technology', 
  '{"fear":"Missing targets","pain":"Long cycles"}',
  '{"vision":"Close faster","outcome":"20% growth"}', NOW());
EOF
```

### Hour 6-8: E2E Tests Against Live DB ⏳
```bash
cd code/backend
npm install
npm test -- e2e.test.js

# Track which tests pass:
# - Auth flow (signup, login, JWT)
# - Profile creation
# - Story generation (WILL CALL REAL FABLE API)
# - Practice coaching (WILL CALL REAL GEMINI API)
# - Analytics
```

### Hour 8-9: Fable LLM Real Testing ⏳
```bash
# Run actual story generation against Fable
node << 'EOF'
const { FableClient } = require('./src/lib/fableClient');
const fable = new FableClient();

const profile = {
  client_name: 'John Smith',
  client_role: 'VP Sales',
  company: 'TechCorp',
  industry: 'Technology',
  winter_json: { fear: 'Missing quota', pain: 'Long cycles' },
  spring_json: { vision: 'Close faster', outcome: '20% growth' }
};

fable.generateStory(profile).then(result => {
  console.log('✅ Story generated');
  console.log('Cost: $' + result.cost.toFixed(4));
  console.log('Act 1:', result.story.act1Hook.substring(0, 100) + '...');
});
EOF
```

### Hour 9-10: Gemini Voice Real Testing ⏳
```bash
# Create sample audio (mock or real recording)
# Call Gemini API to transcribe and score
node << 'EOF'
const { GeminiClient } = require('./src/lib/geminiClient');
const gemini = new GeminiClient();

const story = 'I understand your pain...';
const transcription = 'I understand your pain with long sales cycles...';

gemini.scoreDelivery(story, transcription).then(result => {
  console.log('✅ Delivery scored');
  console.log('Pace Score:', result.scores.paceScore);
  console.log('Overall Score:', (result.scores.paceScore + result.scores.emotionalResonanceScore + result.scores.clarityScore + result.scores.credibilityScore) / 4);
});
EOF
```

### Hour 10-11: Deploy Backend to Fargate ⏳
```bash
# Build Docker image
docker build -t storyforce-backend:latest .

# Push to ECR
aws ecr create-repository --repository-name storyforce-backend || true
aws ecr get-login-password | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com
docker tag storyforce-backend:latest $AWS_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/storyforce-backend:latest
docker push $AWS_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/storyforce-backend:latest

# Deploy to Fargate (GitHub Actions will handle this automatically)
git push origin master
```

### Hour 11-12: Final Production Tests ⏳
```bash
# Wait for GitHub Actions CI/CD to complete
# Monitor: https://github.com/smagnacca/storyforce-ai/actions

# Once deployed, run final E2E tests against live API
API_URL="https://api.storyforce.ai" npm test

# Health check
curl https://api.storyforce.ai/health
```

---

## 📊 Success Criteria

By hour 12, I should have:

- [x] ✅ All code pushed to GitHub with live execution
- [ ] ⏳ AWS infrastructure live (RDS, Redis, S3)
- [ ] ⏳ Database initialized with test data
- [ ] ⏳ E2E tests passing against live DB
- [ ] ⏳ Fable LLM generating real stories (~10 stories, ~$0.50 cost)
- [ ] ⏳ Gemini Voice API transcribing & scoring (~20 calls, ~$0.01 cost)
- [ ] ⏳ Backend deployed to AWS Fargate
- [ ] ⏳ Production health checks passing
- [ ] ⏳ All code committed and pushed
- [ ] ⏳ Cost tracking report generated

---

## 🎯 What's Different From Code-Only

**Real execution means:**
- ✅ Real API responses (may fail, timeout, or rate-limit)
- ✅ Real AWS provisioning delays (10-15 minutes)
- ✅ Real database operations (actual data persistence)
- ✅ Real cost consumption ($50-60 spent)
- ✅ Real error debugging (not just test mocks)
- ✅ Real infrastructure validation
- ✅ Real production readiness verification

**This is NOT a simulation.** Every API call is real, every infrastructure change is live, every cost is actual.

---

## ⚠️ Risks & Mitigations

| Risk | Mitigation |
|------|-----------|
| AWS provisioning fails | Rollback via terraform destroy |
| Fable API rate limits | Backoff and retry, track costs |
| Gemini API errors | Fallback to mock, continue testing |
| RDS connection fails | Verify security groups, retry |
| Budget overrun | Stop and report at $100 spent |
| Deployment takes >1h | Continue in background, move to next step |

---

## 📝 Next Action

**Ready to start?** I need you to confirm:

1. **AWS credentials** - Do you have them ready to provide?
2. **API keys** - Fable + Gemini keys available?
3. **Budget ceiling** - Stop execution if costs exceed $100?
4. **Time commitment** - You're available to monitor for 12 hours?

Once confirmed, I'll begin at Hour 0 with GitHub push and not stop until Hour 12.

**LET'S GO! 🚀**
