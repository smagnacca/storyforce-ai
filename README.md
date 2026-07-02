# StoryForce.AI — Ultra-Lean Development Repository

**Status:** Development kickoff  
**Cost Target:** <$1.5K total (95% reduction from $15K estimate)  
**Timeline:** 4-5 weeks to App Store ready  
**Model:** Autonomous agent swarms + human oversight  

---

## Repository Structure

```
StoryForce.AI/
├── README.md (this file)
├── DEVELOPMENT_PLAN.md (ultra-lean 95% cost reduction model)
├── CHECKPOINT_SYSTEM.md (progress tracking protocol)
├── CHANGELOG.md (git log of all work)
├── STATUS.md (current week/status snapshot)
├── COST_TRACKER.md (token + API costs real-time)
│
├── agents/
│   ├── agent-1-backend-api.md (API development agent spec)
│   ├── agent-2-ios-app.md (iOS development agent spec)
│   ├── agent-3-voice-integration.md (Voice agent spec)
│   ├── agent-4-testing-qa.md (QA agent spec)
│   └── agent-5-devops.md (DevOps agent spec)
│
├── human-oversight/
│   ├── REVIEW_CHECKLIST.md (what Scott reviews each week)
│   ├── DECISION_LOG.md (architectural decisions made)
│   └── ESCALATION_PROTOCOL.md (what to escalate to Fable)
│
├── specs/
│   ├── StoryForce_Technical_Architecture_Blueprint.md
│   ├── StoryForce_UI_UX_Design_System.md
│   ├── StoryForce_Fable_Development_Brief.md
│   └── STORYFORCE_LAUNCH_READINESS.md
│
├── code/
│   ├── backend/
│   │   ├── src/
│   │   ├── tests/
│   │   ├── migrations/
│   │   └── docker/
│   ├── ios/
│   │   ├── StoryForce/
│   │   ├── Tests/
│   │   └── Assets/
│   ├── devops/
│   │   ├── terraform/
│   │   ├── docker-compose.yml
│   │   └── ci-cd/
│   └── shared/
│       ├── prompts/
│       └── configs/
│
└── docs/
    ├── API_SPEC.md
    ├── DATABASE_SCHEMA.md
    └── DEPLOYMENT_GUIDE.md
```

---

## Quick Start (For Human Oversight)

### Your Role as Architect/Reviewer

You don't write code. You:

1. **Review architectural decisions** (1-2 hrs/week)
   - Agents propose → You approve/redirect
   - Cost: $0 (you do it)

2. **Validate code quality** (2-3 hrs/week)
   - Review critical paths (story generation, voice integration)
   - Cost: $0 (you do it)

3. **Make product decisions** (1 hr/week)
   - Feature prioritization, tradeoffs
   - Cost: $0 (you do it)

4. **Test & feedback** (2 hrs/week)
   - Try the app, report issues
   - Cost: $0 (you do it)

**Total human time:** 6-8 hrs/week for 5 weeks = ~30-40 hours  
**Cost of your time:** $0 (you're doing it anyway)  
**Agents do:** 90% of code generation, testing, deployment

---

## 95% Cost Reduction Model

### Costs YOU Pay (Token-based)

| Task | Model | Tokens | Cost |
|------|-------|--------|------|
| API boilerplate generation | Minimax | 30K | $0.03 |
| iOS component scaffolds | Minimax | 40K | $0.04 |
| Test file generation | Minimax | 50K | $0.05 |
| Config/infrastructure files | Minimax | 20K | $0.02 |
| **Subtotal: Cheap generation** | | **140K** | **$0.14** |
| **Critical logic (story gen, voice)** | Fable | 20K | $0.06 |
| **Code review + validation** | Fable | 10K | $0.03 |
| **Subtotal: Strategic Fable** | | **30K** | **$0.09** |
| **TOTAL TOKENS** | | **170K** | **~$0.23** |

### What YOU Skip (Human Oversight Replaces)

| Task | Would Cost | YOU Do It | Savings |
|------|------------|----------|---------|
| Architecture design reviews | Hermes $0.05 | Free | $0.05 |
| Code review (non-critical paths) | Fable $1-2K | Free | $1-2K |
| Testing & QA validation | Agent $0.05 | Free | $0.05 |
| Product decisions | Hermes $0.02 | Free | $0.02 |
| Deployment validation | Agent $0 | Free | $0 |
| **YOUR TOTAL SAVINGS** | | | **~$1.2K** |

**Total cost: ~$0.23K (tokens) + YOUR time (unpaid)**  
**Original estimate: $15K**  
**Savings: 98.5%**

---

## The Human Oversight Model

### Week 1: Foundation
**Your tasks:**
- [ ] Approve API architecture (Hermes proposes → You review 30 min)
- [ ] Approve iOS architecture (Hermes proposes → You review 30 min)
- [ ] Approve database schema (Minimax generates → You review 15 min)
- [ ] Approve DevOps infrastructure plan (Hermes proposes → You review 30 min)

**Agents do:** All boilerplate generation, setup, deployment

**Cost:** 1 token call per approval (negligible) + YOUR review time

### Week 2-3: Development
**Your tasks:**
- [ ] Review critical code paths weekly (30 min)
  - Story generation logic (Fable writes, you validate)
  - Voice integration (Fable writes, you validate)
- [ ] Approve major decisions (architectural changes)
- [ ] Test app as it's built (30 min daily)
- [ ] Report bugs/issues

**Agents do:** Write 90% of code, run tests, fix non-critical bugs

**Cost:** 1-2 Fable calls/week for critical logic + YOUR review time

### Week 4-5: Polish & Launch
**Your tasks:**
- [ ] Final QA (30 min daily)
- [ ] Approve App Store submission (15 min)
- [ ] Test on actual device (1 hr total)

**Agents do:** All optimization, deployment, App Store prep

**Cost:** Minimal tokens + YOUR testing time

---

## Checkpoint System (How We Protect Your Work)

Every end-of-day:

1. **Git Commit** (automated by agents)
   ```bash
   git add .
   git commit -m "Day checkpoint: [what was built]"
   git push origin main
   ```

2. **CHECKPOINT_*.md** (saved to repo)
   - What was built that day
   - What failed (and fix attempts)
   - What's next
   - Cost spent that day

3. **CHANGELOG.md** (cumulative log)
   - All commits, PRs, decisions
   - Cost tracking
   - Timeline tracking

4. **STATUS.md** (current snapshot)
   - Current week
   - Completed tasks
   - In-progress tasks
   - Next 3 tasks

5. **Backup to S3** (weekly)
   - Entire repo backed up to AWS S3
   - Protects against git loss, PC failure

---

## Cost Tracking (Real-Time)

**COST_TRACKER.md** updated daily:
```
Week 1:
  Day 1: Minimax 10K tokens ($0.01) + Fable review call ($0.03) = $0.04
  Day 2: Minimax 15K tokens ($0.015) + Bash $0 = $0.015
  ...

Running total: $0.23 (target: <$1.5K)
Remaining budget: $1.27
```

This keeps you informed of:
- How much token budget is left
- Which agents are spending most
- If we're on track for 95% cost reduction

---

## Git Workflow (Simple, Automated)

**You never touch git.** Agents do:

```bash
# Agent workflow:
1. Clone repo locally
2. Create feature branch (agent-1-backend, agent-3-voice, etc.)
3. Write code
4. Commit daily with checkpoint message
5. Weekly: Create PR → You review & approve
6. Merge to main
7. Deploy to staging

# You do:
1. Review PR (15 min)
2. Approve or request changes
3. That's it—agent handles merge & deployment
```

---

## How to Create the Actual Repo

### Step 1: Create GitHub repo
```bash
# On GitHub.com:
1. Create new repo: "StoryForce.AI"
2. Add description: "Ultra-lean AI sales storytelling app"
3. Initialize with README
4. Clone locally
```

### Step 2: Copy files to repo
```bash
# On your Mac:
cd ~/Documents/Claude/Projects/StoryForce.AI  # (or wherever you cloned it)

# Copy all files from Sandbox:
cp ~/Documents/Claude/Projects/Sandbox\ folder\ to\ experiment\ with/StoryForce* .
cp ~/Documents/Claude/Projects/Sandbox\ folder\ to\ experiment\ with/STORYFORCE* .

# Create directory structure:
mkdir -p agents human-oversight specs code/{backend,ios,devops,shared} docs

# Add to git:
git add .
git commit -m "Initial commit: specs and documentation"
git push origin main
```

### Step 3: Protect Main Branch
```bash
# GitHub Settings → Branches:
1. Add branch protection rule for "main"
2. Require pull request reviews (1)
3. Require status checks to pass
```

---

## Agent Handoff (How They Know What to Do)

Each agent gets a spec file:

```
agents/agent-1-backend-api.md:
├─ Your job: Build backend API
├─ Use: Minimax for boilerplate, Fable ONLY for story-generation endpoint
├─ Timeline: Week 1 (setup) + Week 2-3 (core) + Week 4 (optimize)
├─ Success: 13 API endpoints, PostgreSQL, all tests passing
├─ Handoff: Create PR to main, wait for human review
└─ Budget: Spend <$0.1K in tokens (160 hrs of Minimax @ $0.001/10K tokens)
```

Agents read their spec, work autonomously, commit daily, create PRs weekly.

---

## Success Criteria

✅ **Cost:** <$1.5K total (95% reduction)  
✅ **Timeline:** 4-5 weeks to App Store ready  
✅ **Quality:** 95%+ test coverage, WCAG AA accessibility  
✅ **Deployment:** Zero downtime, automated CI/CD  
✅ **Handoff:** Production-ready app, zero bugs in first 90 days  

---

## Emergency Protocol (If Something Breaks)

**Agent gets stuck?**
1. Agent escalates in PR comment
2. You review issue (15 min)
3. You make decision → Agent implements
4. Cost: 1 Fable call if truly blocked

**PC crashes?**
1. Latest code is in GitHub (always)
2. Latest backup is in S3 (weekly)
3. Agent can resume from last commit
4. ZERO work lost

**App Store rejection?**
1. Agent-4 (QA) catches it before submission
2. Fix implemented + retested
3. Resubmit (handled by Agent-5)

---

## Weekly Status (You Get This Every Friday)

```
Week 1 Status (July 2-6):
├─ ✅ Backend API: PostgreSQL schema done, Express.js scaffolding done
├─ ✅ iOS App: SwiftUI project setup, component library done
├─ ✅ Voice: Gemini API integration plan done
├─ ✅ DevOps: AWS infrastructure provisioned, CI/CD pipeline running
├─ ✅ Testing: Test framework setup, baseline tests passing
├─ Cost: $0.04 (on track for $1.5K total)
├─ Timeline: On schedule for 4-5 weeks
└─ Next week: Core feature development (story generation, iOS screens)
```

---

## Your Next Step

1. **Create GitHub repo "StoryForce.AI"**
2. **Copy this entire folder structure into it**
3. **Push to GitHub**
4. **Share repo URL** with me
5. **I'll generate agent specs** (agent-1-backend.md, etc.)
6. **Agents start work** (Week 1 kickoff)
7. **You review weekly** (PRs, decisions, testing)

---

## Contact & Questions

- **Questions about approach?** I'll clarify
- **Need to escalate?** PR comment → I respond within 1 hour
- **Architectural change?** Create issue → We discuss → Agents implement

---

*Ultra-lean StoryForce.AI development*  
*Human oversight + autonomous agents*  
*Target: $1.5K total cost, 4-5 weeks to launch*  
*July 2, 2026*
