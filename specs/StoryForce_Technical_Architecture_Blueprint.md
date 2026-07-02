# StoryForce — Complete Technical Architecture Blueprint
## iOS Storyselling Story Engine with Google Gemini Voice Integration

**Document Purpose:** Complete handoff specification for Claude Fable to implement MVP  
**Last Updated:** July 2, 2026  
**Status:** Architecture Finalized → Ready for Development

---

## EXECUTIVE SUMMARY

**StoryForce** is a mobile-first AI coaching app that helps B2B sales reps generate research-backed Three-Act stories in real-time, powered by Claude Fable (story generation) and Google Gemini Voice (conversational coaching).

**Core Workflow:**
1. Rep describes client in natural voice
2. App clarifies via Gemini Voice conversation
3. Fable generates Three-Act story
4. Rep practices with Gemini as skeptical client
5. App scores delivery quality, saves story + metrics

**Primary Stack:**
- **Mobile:** SwiftUI (iOS), cross-platform via React Native
- **LLM (Story Engine):** Claude Fable
- **Voice/Conversation:** Google Gemini Voice API
- **Backend:** Node.js/Express or Python FastAPI
- **Database:** PostgreSQL (user data) + Firebase/Supabase (realtime)
- **Hosting:** AWS or GCP (App deployed on App Store, backend on cloud)

---

## 1. SYSTEM ARCHITECTURE OVERVIEW

### High-Level Data Flow

```
┌──────────────────────────────────────────────────────────────────┐
│                         iOS App (SwiftUI)                         │
│  ┌─────────────────────────────────────────────────────────────┐ │
│  │ Voice Input → NLP Parser → Story Generator → Practice Coach │ │
│  │ (Gemini Voice) (Local/API) (Fable LLM)    (Gemini Voice)   │ │
│  └─────────────────────────────────────────────────────────────┘ │
└──────────────────────────┬───────────────────────────────────────┘
                           │
                  ┌────────▼────────┐
                  │   API Gateway   │
                  │ (Authentication)│
                  └────────┬────────┘
                           │
        ┌──────────────────┼──────────────────┐
        │                  │                  │
    ┌───▼───┐         ┌────▼────┐       ┌────▼────┐
    │ Fable │         │ Gemini   │       │Database │
    │ LLM   │         │ Voice    │       │(Stories)│
    │Engine │         │API       │       │Analytics│
    └───────┘         └──────────┘       └─────────┘
```

### Key Components

| Component | Purpose | Tech Stack |
|-----------|---------|-----------|
| **iOS Frontend** | Client-facing app | SwiftUI, AVFoundation (audio capture) |
| **API Gateway** | Route requests, manage auth | Express.js middleware or AWS API Gateway |
| **Fable LLM Service** | Story generation + personalization | Claude Fable API calls |
| **Gemini Voice Service** | Speech-to-text, text-to-speech, dialogue | Google Gemini Voice API |
| **Story Database** | Persist user stories, case library | PostgreSQL + Redis cache |
| **Analytics Engine** | Track conversions, delivery quality | Supabase RLS or custom REST endpoints |
| **Authentication** | User sign-up, login, free/paid gates | Firebase Auth or Auth0 |

---

## 2. DATA MODELS & SCHEMAS

### User Model
```json
{
  "id": "uuid",
  "email": "rep@company.com",
  "firstName": "John",
  "lastName": "Doe",
  "company": "Acme Consulting",
  "role": "Account Executive",
  "subscriptionTier": "professional | free | team | enterprise",
  "subscriptionStatus": "active | trial | expired",
  "storysCompletedThisMonth": 42,
  "practiceSessionsCompletedThisMonth": 15,
  "conversionsThisQuarter": 8,
  "createdAt": "2026-06-15T10:30:00Z",
  "lastActiveAt": "2026-07-02T14:22:00Z",
  "onboardingComplete": true
}
```

### Client Profile (Extracted from Voice/Text)
```json
{
  "id": "uuid",
  "userId": "uuid",
  "clientName": "Mike Johnson",
  "clientRole": "VP Operations",
  "company": "Pharma Corp Inc",
  "industry": "pharmaceutical",
  "currentWinter": {
    "primaryFear": "Cost containment + operational disruption",
    "secondaryFears": ["Trust in consultants", "Implementation timeline"],
    "painPoints": ["Budget cuts", "Legacy system constraints"],
    "decisionStyle": "analytical_but_risk_averse",
    "timeline": "Q3 2026"
  },
  "desiredSpring": {
    "mainGoal": "Reduce operational costs by 20% without disrupting service",
    "successMetrics": ["Cost savings", "Team confidence", "Zero downtime"],
    "emotionalOutcome": "Confidence, control, legacy preservation"
  },
  "contextNotes": "First-time working with consultants, previous bad experience with implementation",
  "extractedFrom": "voice | text",
  "transcription": "Mike is a VP of Operations worried about cost...",
  "createdAt": "2026-07-02T14:15:00Z"
}
```

### Story Object (Generated)
```json
{
  "id": "uuid",
  "userId": "uuid",
  "clientProfileId": "uuid",
  "storyVersion": 1,
  "generatedAt": "2026-07-02T14:20:00Z",
  "threeActStructure": {
    "act1_hook": {
      "text": "I see your fear. You've been burned before by consultants...",
      "duration_seconds": 45,
      "emotionalTarget": "safety | confidence | understanding"
    },
    "act2_bridge": {
      "text": "I had a client named Sarah, VP of Operations at MediTech...",
      "caseStudyReference": "case_001_meditech",
      "duration_seconds": 120,
      "metrics": ["Cost reduction: 18%", "Timeline: 6 months", "Team satisfaction: 9/10"]
    },
    "act3_payoff": {
      "text": "By following the same approach, you'll retire confidence that...",
      "springVision": "You're running lean, your team trusts the process, stakeholders are thrilled",
      "duration_seconds": 60
    }
  },
  "metaphors": [
    {
      "metaphor": "Like a gardener trimming branches—removing waste, not health",
      "applicability_score": 0.92,
      "industry": "operations"
    }
  ],
  "deliveryGuidance": {
    "pace": "slow",
    "tone": "empathetic_then_confident",
    "pausePoints": ["After act1_hook", "Before act3_payoff"],
    "bodyLanguageCues": "Make eye contact during 'I see your fear', gesture forward during spring vision"
  },
  "practiceAttempts": [
    {
      "attemptNumber": 1,
      "deliveryAudio": "audio_blob_url",
      "geminiAnalysis": {
        "paceScore": 7,
        "emotionalResonanceScore": 6,
        "clarityScore": 8,
        "credibilityScore": 7,
        "overallScore": 7.0,
        "feedback": "Good structure, but rushed through Act 1. Pause after 'I see your fear' for 2 seconds."
      }
    },
    {
      "attemptNumber": 2,
      "deliveryAudio": "audio_blob_url",
      "geminiAnalysis": {
        "overallScore": 8.2,
        "feedback": "Much better! You sound confident now. One more take: add a personal touch to Act 2."
      }
    }
  ],
  "finalDeliveryScore": 8.2,
  "meetingOutcome": {
    "meetingDate": "2026-07-05",
    "result": "won | lost | pending",
    "dealValue": 250000,
    "dealCurrency": "USD",
    "storyHelpfulnessRating": 9,
    "clientFeedback": "That story really resonated with my situation"
  }
}
```

### Case Study Library
```json
{
  "id": "case_001_meditech",
  "industry": "pharmaceutical",
  "clientType": "operations_executive",
  "challenge": "Cost reduction + implementation risk",
  "solution": "Phased optimization approach with stakeholder alignment",
  "results": {
    "cost_reduction_percent": 18,
    "implementation_months": 6,
    "team_satisfaction": 9
  },
  "narrative": "Sarah was a VP of Operations at MediTech, worried about disrupting...",
  "generatedFromSource": "scott_magnacca_client_work | babson_case_study | novartis_implementation",
  "applicableIndustries": ["pharmaceutical", "healthcare", "biotech"],
  "applicableRoles": ["operations", "finance", "cfo"],
  "conversionRate": 0.72
}
```

---

## 3. API ARCHITECTURE

### Core Endpoints

#### Authentication
```
POST /auth/signup
  Body: { email, password, firstName, lastName, company, role }
  Response: { userId, authToken, subscriptionTier }

POST /auth/login
  Body: { email, password }
  Response: { userId, authToken, subscriptionTier }

POST /auth/refresh
  Body: { refreshToken }
  Response: { newAuthToken }
```

#### Client Profile Management
```
POST /api/client-profiles
  Headers: Authorization: Bearer {token}
  Body: { clientName, clientRole, company, industry, winter, spring, contextNotes }
  Response: { clientProfileId, extractedData }

GET /api/client-profiles/:id
  Response: ClientProfile object

GET /api/client-profiles?userId={userId}&limit=10
  Response: [ClientProfile, ...] (paginated)
```

#### Story Generation
```
POST /api/stories/generate
  Headers: Authorization: Bearer {token}
  Body: { 
    clientProfileId, 
    storyType: "three_act" | "metaphor_only",
    preferredLength: "short" | "medium" | "long",
    industryFocus: "financial | consulting | pharma"
  }
  Response: { storyId, threeActStructure, metaphors, deliveryGuidance }
  Backend Logic:
    1. Validate subscription tier (free users: 5/mo, professional: unlimited)
    2. Fetch client profile
    3. Call Fable LLM with prompt template + client context
    4. Generate Three-Act story
    5. Save to database
    6. Return story + practice session token
```

#### Voice-to-Client-Profile (Gemini Speech-to-Text)
```
POST /api/profiles/from-voice
  Headers: Authorization: Bearer {token}, Content-Type: multipart/form-data
  Body: { audioFile, companyContext, productServiceFocus }
  Response: { clientProfileId, extractedProfile, confirmationQuestions }
  Backend Logic:
    1. Receive audio blob from iOS app
    2. Call Google Gemini Voice API (speech-to-text)
    3. Extract entities: name, role, company, industry, pain points, goals
    4. Return extracted profile
    5. (Optional: Ask Gemini for 2-3 clarifying questions)
```

#### Practice Coaching (Voice)
```
POST /api/stories/:storyId/practice
  Headers: Authorization: Bearer {token}, Content-Type: multipart/form-data
  Body: { audioFile, attemptNumber }
  Response: { attemptId, geminiAnalysis, feedback, scores, nextAction }
  Backend Logic:
    1. Receive audio (rep speaking their story)
    2. Call Google Gemini Voice (speech-to-text)
    3. Transcribe rep's delivery
    4. Analyze with Fable:
       - Does it follow Three-Act structure?
       - Emotional resonance?
       - Clarity for client understanding?
       - Credibility/trust-building?
    5. Call Google Gemini Voice (text-to-speech) to deliver feedback aloud
    6. Save practice attempt + scores
    7. Return guidance for next take
```

#### Story Analytics
```
GET /api/stories?userId={userId}&timeframe=week|month|quarter
  Response: {
    totalStoriesGenerated: 42,
    practiceSessionsCompleted: 15,
    storiesTakenToMeetings: 12,
    conversionRate: 0.67,
    topPerformingStories: [story_ids],
    avgDeliveryScore: 7.8,
    trends: { weekOverWeekGrowth: 1.15 }
  }

GET /api/stories/:storyId/performance
  Response: {
    storyId,
    meetingsUsed: 3,
    winRate: 0.67,
    avgClientFeedback: 8.5,
    timesSaved: 12
  }
```

---

## 4. VOICE INTEGRATION ARCHITECTURE

### Google Gemini Voice API Integration

#### Speech-to-Text Pipeline (Client → App → Gemini → API)
```
┌─────────────────────────────────────────────────────┐
│  iOS App (AVAudioEngine captures microphone)        │
│  ├─ Samples audio in real-time                      │
│  ├─ Sends 1-2 sec chunks to backend                 │
│  └─ UI shows "Listening..." spinner                 │
└────────────────────┬────────────────────────────────┘
                     │
        ┌────────────▼───────────────┐
        │  Express API Handler       │
        │  /api/profiles/from-voice  │
        │  Receives audio blob       │
        └────────────────┬───────────┘
                         │
        ┌────────────────▼──────────────────┐
        │ Google Gemini Voice API           │
        │ speech_to_text(audio_bytes)       │
        │ → Returns: transcription + entities
        └────────────────┬──────────────────┘
                         │
        ┌────────────────▼──────────────────┐
        │ NLP Post-Processing (Fable)       │
        │ Extract: name, role, company,     │
        │ industry, pain points, goals      │
        │ → Returns: structured profile     │
        └────────────────┬──────────────────┘
                         │
        ┌────────────────▼──────────────────┐
        │ (Optional) Clarifying Questions   │
        │ Gemini generates follow-ups       │
        │ text_to_speech() → iOS hears      │
        └────────────────┬──────────────────┘
                         │
        ┌────────────────▼──────────────────┐
        │ Save ClientProfile to Database    │
        │ Return profile ID to app          │
        └──────────────────────────────────┘
```

#### Text-to-Speech Pipeline (Story Coaching)
```
┌─────────────────────────────────────────────────────┐
│  Story Generated + Delivery Feedback Ready          │
│  (Fable analyzed rep's practice attempt)            │
└────────────────────┬────────────────────────────────┘
                     │
        ┌────────────▼──────────────────┐
        │ Format Feedback for Voice      │
        │ (Fable output → natural lang)  │
        └────────────────┬───────────────┘
                         │
        ┌────────────────▼──────────────────┐
        │ Google Gemini Voice API           │
        │ text_to_speech(feedback_text)     │
        │ → Returns: audio stream           │
        └────────────────┬──────────────────┘
                         │
        ┌────────────────▼──────────────────┐
        │ iOS App (AVAudioEngine)           │
        │ Plays coaching feedback in voice  │
        │ User hears: "Great pace, but..." │
        └──────────────────────────────────┘
```

#### Real-Time Conversation Loop (Gemini as Skeptical Client)
```
Rep speaks story → Gemini transcribes → Analyzes structure → 
Responds as "skeptical client" (text) → Text-to-speech → 
Rep hears objection → Rep responds → Loop repeats
```

### Gemini Voice Implementation Notes

**Streaming vs. Batch:**
- Use **streaming** for real-time conversation (speech-to-text as rep speaks)
- Use **batch** for async voice feedback (generate coaching message, then TTS)

**Latency Targets:**
- Speech-to-text: <1 sec (so rep doesn't feel lag)
- Feedback TTS: <2 sec (acceptable for coaching)
- Full loop: <5 sec (conversation feels natural)

**Error Handling:**
- If Gemini API fails: fall back to text-based coaching
- If audio quality poor: prompt rep to move to quieter location
- Timeouts: auto-save partial recordings, allow retry

---

## 5. STORY GENERATION PIPELINE

### Fable LLM Integration (Core Engine)

#### Prompt Template for Three-Act Story Generation
```
You are a world-class B2B sales coach trained in narrative intelligence 
and the Storyselling methodology.

CLIENT CONTEXT:
- Name: {client.name}
- Role: {client.role}
- Company: {client.company}
- Industry: {client.industry}

CURRENT STATE (Winter):
{client.winter.description}

DESIRED STATE (Spring):
{client.spring.description}

Your task: Generate a Three-Act story that helps this client see 
themselves moving from Winter to Spring. Follow this structure:

ACT 1 - THE HOOK (45 seconds):
- Start with empathy: "I see your {primary_fear}..."
- Show understanding of their situation
- Build psychological safety

ACT 2 - THE BRIDGE (2 minutes):
- Tell a story about a similar client (use case study: {caseStudyName})
- How did you help them overcome the same fear?
- What specific actions did they take?
- What were the results? (metrics + emotional outcome)

ACT 3 - THE PAYOFF (60 seconds):
- Paint a vivid picture of their Spring
- Use specific details from their context
- End with a natural transition to next steps

TONE: Empathetic, confident, specific, not salesy
LENGTH: ~1000-1200 words
FORMAT: Markdown with clear section headers

ALSO GENERATE:
- 3 relevant metaphors for this industry + situation
- Delivery guidance (pace, tone, pauses, body language cues)
- Potential objections + brief counter-stories
```

#### Fable API Call
```python
import anthropic

client = anthropic.Anthropic(api_key="sk-...")

def generate_story(client_profile, case_study_reference):
    prompt = STORY_TEMPLATE.format(
        client=client_profile,
        caseStudyName=case_study_reference
    )
    
    response = client.messages.create(
        model="claude-fable-5",
        max_tokens=2000,
        messages=[
            {"role": "user", "content": prompt}
        ]
    )
    
    story_text = response.content[0].text
    # Parse story into structured format
    return parse_three_act_story(story_text)

def parse_three_act_story(text):
    # Use regex or Claude to extract:
    # - Act 1 Hook
    # - Act 2 Bridge + case study reference
    # - Act 3 Payoff
    # - Metaphors
    # - Delivery guidance
    return {
        "act1_hook": extract_act1(text),
        "act2_bridge": extract_act2(text),
        "act3_payoff": extract_act3(text),
        "metaphors": extract_metaphors(text),
        "deliveryGuidance": extract_delivery_guidance(text)
    }
```

#### Case Study Library (Pre-Built)
- Source: Scott's book chapters, Babson course materials, Novartis implementations
- Pre-load 20–30 industry-specific case studies into database
- Tag by: industry, role, challenge, solution, results
- Fable references these when generating Act 2 Bridge stories
- Format: Structured JSON with company, challenge, solution, metrics, narrative

---

## 6. DATABASE SCHEMA

### PostgreSQL Core Tables

```sql
-- Users
CREATE TABLE users (
  id UUID PRIMARY KEY,
  email VARCHAR(255) UNIQUE NOT NULL,
  passwordHash VARCHAR(255) NOT NULL,
  firstName VARCHAR(100),
  lastName VARCHAR(100),
  company VARCHAR(255),
  role VARCHAR(100),
  subscriptionTier VARCHAR(50) DEFAULT 'free',
  subscriptionStartDate TIMESTAMP,
  subscriptionExpiryDate TIMESTAMP,
  storiesGeneratedThisMonth INT DEFAULT 0,
  practiceSessionsThisMonth INT DEFAULT 0,
  createdAt TIMESTAMP DEFAULT NOW(),
  lastActiveAt TIMESTAMP,
  onboardingComplete BOOLEAN DEFAULT FALSE
);

-- Client Profiles
CREATE TABLE client_profiles (
  id UUID PRIMARY KEY,
  userId UUID NOT NULL REFERENCES users(id),
  clientName VARCHAR(255),
  clientRole VARCHAR(100),
  company VARCHAR(255),
  industry VARCHAR(100),
  winterJson JSONB, -- Stores fear, pain points, etc.
  springJson JSONB, -- Stores goals, vision, etc.
  extractedFrom VARCHAR(50), -- 'voice' or 'text'
  transcription TEXT,
  createdAt TIMESTAMP DEFAULT NOW(),
  updatedAt TIMESTAMP DEFAULT NOW()
);

-- Stories Generated
CREATE TABLE stories (
  id UUID PRIMARY KEY,
  userId UUID NOT NULL REFERENCES users(id),
  clientProfileId UUID NOT NULL REFERENCES client_profiles(id),
  storyVersion INT,
  threeActJson JSONB, -- act1_hook, act2_bridge, act3_payoff
  metaphorsJson JSONB,
  deliveryGuidanceJson JSONB,
  finalDeliveryScore DECIMAL(3,1),
  createdAt TIMESTAMP DEFAULT NOW()
);

-- Practice Attempts
CREATE TABLE practice_attempts (
  id UUID PRIMARY KEY,
  storyId UUID NOT NULL REFERENCES stories(id),
  attemptNumber INT,
  audioUrl VARCHAR(255), -- S3/GCS path
  transcription TEXT,
  geminiAnalysisJson JSONB, -- pace, resonance, clarity, credibility scores
  overallScore DECIMAL(3,1),
  feedback TEXT,
  createdAt TIMESTAMP DEFAULT NOW()
);

-- Meeting Outcomes
CREATE TABLE meeting_outcomes (
  id UUID PRIMARY KEY,
  storyId UUID NOT NULL REFERENCES stories(id),
  meetingDate DATE,
  result VARCHAR(50), -- 'won' | 'lost' | 'pending'
  dealValue DECIMAL(12,2),
  dealCurrency VARCHAR(3),
  storyHelpfulnessRating INT, -- 1-10
  clientFeedback TEXT,
  recordedAt TIMESTAMP DEFAULT NOW()
);

-- Case Studies (Pre-loaded)
CREATE TABLE case_studies (
  id VARCHAR(100) PRIMARY KEY,
  industry VARCHAR(100),
  clientType VARCHAR(100),
  challenge TEXT,
  solution TEXT,
  resultsJson JSONB,
  narrative TEXT,
  generatedFromSource VARCHAR(255),
  conversionRate DECIMAL(3,2)
);

-- Analytics (Denormalized for speed)
CREATE TABLE user_analytics (
  userId UUID PRIMARY KEY REFERENCES users(id),
  totalStoriesGenerated INT DEFAULT 0,
  practiceSessionsCompleted INT DEFAULT 0,
  storiesTakenToMeetings INT DEFAULT 0,
  dealsWon INT DEFAULT 0,
  conversionRate DECIMAL(3,2),
  avgDeliveryScore DECIMAL(3,1),
  lastUpdated TIMESTAMP DEFAULT NOW()
);
```

### Firebase Realtime (Optional, for live coaching)
```json
{
  "activeCoachingSessions": {
    "{sessionId}": {
      "userId": "uuid",
      "storyId": "uuid",
      "status": "in_progress",
      "transcribedSoFar": "The story starts...",
      "geminiFeedback": "Good pace so far...",
      "timestamp": 1719949200000
    }
  }
}
```

---

## 7. AUTHENTICATION & SECURITY

### OAuth2 + JWT Strategy
```
Sign-up/Login → Firebase Auth or Auth0
  ↓
Issue JWT (access token + refresh token)
  ↓
iOS app stores in Secure Enclave
  ↓
Every API call includes: Authorization: Bearer {jwt}
  ↓
Backend validates JWT, checks subscription tier
  ↓
Grant/deny access based on tier (free, pro, team, enterprise)
```

### Subscription Tier Gating
```python
@require_auth
def generate_story(request, client_profile_id):
    user = request.user
    
    # Check subscription tier
    if user.subscription_tier == "free":
        if user.stories_generated_this_month >= 5:
            return error_403("Upgrade to Professional for unlimited stories")
    
    # Generate story (call Fable)
    story = fable_generate_story(client_profile_id)
    return story_json
```

### Audio Privacy & Compliance
- Audio files stored in encrypted S3/GCS bucket
- Auto-delete after 90 days (GDPR compliant)
- Option for rep to manually delete recordings
- Enterprise tier: on-prem audio storage option

---

## 8. DEPLOYMENT & SCALING

### Deployment Architecture

```
┌─────────────────────────────────────────────────────┐
│              Apple App Store / Google Play          │
│  (StoryForce iOS app, auto-updated, v1.0+)          │
└────────────────────┬────────────────────────────────┘
                     │
        ┌────────────▼───────────────┐
        │    AWS/GCP CloudFront      │
        │    (CDN for static assets) │
        └────────────────┬───────────┘
                         │
        ┌────────────────▼──────────────────┐
        │  API Gateway / Load Balancer      │
        │  (Routes to backend services)     │
        └────────────────┬──────────────────┘
                         │
        ┌────────────────▼──────────────────┐
        │  Containerized Backend (Docker)   │
        │  ├─ Node.js/Express or FastAPI    │
        │  ├─ Replicated (3+ instances)     │
        │  ├─ Auto-scaling on demand        │
        │  └─ Health checks every 30s       │
        └────────────────┬──────────────────┘
                         │
        ┌────────────────▼──────────────────────┐
        │  Database Tier                        │
        │  ├─ PostgreSQL (RDS, managed)         │
        │  ├─ Redis cache (60s TTL)             │
        │  ├─ Automated backups (daily)         │
        │  └─ Read replicas for analytics       │
        └────────────────┬──────────────────────┘
                         │
        ┌────────────────▼──────────────────┐
        │  External APIs                    │
        │  ├─ Claude Fable (story gen)      │
        │  ├─ Google Gemini Voice (audio)   │
        │  └─ Firebase Auth (user mgmt)     │
        └──────────────────────────────────┘
```

### Deployment Steps for Fable
1. **Backend Setup** (Node.js + Express or Python FastAPI)
   - Create `/api/auth`, `/api/client-profiles`, `/api/stories`, `/api/practice` endpoints
   - Set up middleware: JWT validation, rate limiting, logging
   - Connect to PostgreSQL + Redis

2. **LLM Integration** (Claude Fable)
   - Integrate Fable API client
   - Implement story generation prompts
   - Add retry logic + fallbacks

3. **Voice Integration** (Google Gemini)
   - Integrate Gemini Voice API
   - Implement speech-to-text pipeline
   - Implement text-to-speech coaching feedback

4. **iOS App** (SwiftUI)
   - Build UI for client input (voice/text)
   - Build story display screen
   - Build practice coach screen (record, playback, feedback)
   - Implement audio capture (AVAudioEngine)
   - Add API integration (URLSession)

5. **Database & Auth**
   - Create PostgreSQL schema
   - Set up Firebase Auth
   - Implement JWT issuance + validation

6. **Testing & QA**
   - Unit tests for LLM prompts
   - Integration tests for API flows
   - Voice quality tests (various accents, backgrounds)
   - Subscription tier gating tests

7. **Deployment**
   - Docker containerize backend
   - Deploy to AWS/GCP
   - Set up CDN for static assets
   - Submit iOS app to App Store
   - Configure CI/CD (GitHub Actions or similar)

---

## 9. COST ESTIMATES (Monthly, at Scale)

### API Costs

| Service | Usage | Est. Cost |
|---------|-------|-----------|
| **Claude Fable** | 100K stories/mo @ ~500 tokens avg | $200 |
| **Google Gemini Voice** | 50K speech-to-text, 50K text-to-speech @ $0.02/min | $100 |
| **Firebase Auth** | 10K users | ~$0 (free tier) |
| **AWS RDS (PostgreSQL)** | db.t3.small instance | $30 |
| **AWS S3 (audio storage)** | 500GB/mo @ $0.023/GB | $12 |
| **AWS CloudFront (CDN)** | 1TB/mo @ $0.085/GB | $85 |
| **Redis (cache)** | ElastiCache db.t3.micro | $20 |
| **API Gateway & compute** | EC2 or Fargate (2 instances) | $150 |
| **Monitoring (DataDog)** | Minimal | $50 |
| **Misc (DNS, email, etc.)** | | $30 |
| **TOTAL** | | **~$677/month** |

**At 10,000 users (professional tier @ $12.99/mo):**
- Revenue: ~$130K/month
- COGS (infrastructure): ~$2K/month
- Gross margin: 98%

### Development Costs (Fable Implementation)
- Backend API development: 80–100 hours (~$12K–$15K)
- iOS app development: 120–150 hours (~$18K–$22K)
- Voice integration & testing: 40–60 hours (~$6K–$9K)
- Database & deployment: 30–40 hours (~$4K–$6K)
- **Total dev:** ~$40K–$52K (at $150/hr)

---

## 10. DEVELOPMENT TIMELINE FOR FABLE

### Phase 1: MVP (6–8 weeks)
**Week 1–2: Infrastructure & Auth**
- PostgreSQL schema setup
- Firebase Auth integration
- JWT implementation
- Backend scaffolding

**Week 3–4: Core Fable Integration**
- Story generation prompts
- Three-Act template validation
- Metaphor generation
- Integration testing

**Week 5–6: Gemini Voice Integration**
- Speech-to-text pipeline
- Text-to-speech pipeline
- Audio handling (capture, storage, deletion)
- Latency optimization

**Week 7–8: iOS App + Testing**
- SwiftUI frontend (client input, story display, practice coach)
- API integration
- End-to-end testing
- App Store submission prep

### Phase 2: Enhancement (2–3 weeks post-launch)
- Subscription tier gating
- Analytics dashboard
- Case study library expansion
- Performance optimization

### Phase 3: Distribution (Ongoing)
- Launch at Babson Summer Course (July 27–31, 2026)
- Promote to SalesForLife.ai community
- Outreach to financial advisory + consulting firms

---

## 11. SUCCESS METRICS & KPIs

| Metric | Target | Timeline |
|--------|--------|----------|
| **Downloads (iOS)** | 500+ | 30 days post-launch |
| **Free-to-Paid Conversion** | 8%+ | 90 days |
| **Monthly Active Users** | 1,000+ | 6 months |
| **Avg Stories/User/Month** | 3+ | 3 months |
| **NPS (Net Promoter Score)** | 50+ | 60 days |
| **Deal Win Rate Lift** | +15% (self-reported) | 90 days |
| **Retention Rate** | 40%+ monthly | 6 months |

---

## 12. TECHNICAL DEBT & FUTURE ENHANCEMENTS

**Short-term (months 2–3):**
- CRM integrations (Salesforce, HubSpot)
- Team collaboration features (share stories, team leaderboards)
- Advanced analytics (conversion funnel, delivery quality trends)

**Long-term (months 4–6):**
- Video coaching (not just audio)
- AR body language mirror (show rep their posture/gestures)
- Predictive model: which story types convert best for each industry
- White-label version for enterprise customers

---

## 13. ROLL-OUT & DISTRIBUTION STRATEGY

**Pre-Launch (Week 1–2):**
- Beta testing with 20 power users (Scott's network)
- Feedback & iteration
- Press/social media teases

**Launch Day:**
- App Store release
- Announcement to SalesForLife.ai email list
- LinkedIn announcement
- Babson course promotion (launch during event?)

**Post-Launch (Month 1–3):**
- Daily engagement (push notifications: "Try practicing with Gemini today")
- In-app tutorials
- Customer success calls (enterprise tire users)
- Case studies (rep X closed $500K deal after using StoryForce)

**Scaling (Month 3+):**
- Outreach to financial advisory firms
- Partnerships with CRM providers
- Content marketing (blog: Storyselling in B2B sales)
- Webinars featuring app success stories

---

## SUMMARY: READY FOR FABLE DEVELOPMENT

**This blueprint is production-ready.** Fable can:

1. ✅ Build the backend API (Node/Python) with Fable + Gemini integration
2. ✅ Develop the iOS app (SwiftUI) with voice capture + playback
3. ✅ Test end-to-end (story generation → voice practice → feedback)
4. ✅ Deploy to App Store + cloud infrastructure
5. ✅ Hand off to you for beta testing → launch

**Estimated Delivery:** 6–8 weeks from code kickoff

**Next Step:** Approve architecture → Fable begins backend development

---

*Document prepared for Claude Fable implementation*  
*Architecture review completed: July 2, 2026*  
*Status: APPROVED FOR DEVELOPMENT*
