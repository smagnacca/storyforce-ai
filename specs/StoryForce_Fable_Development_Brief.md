# StoryForce — Executive Handoff Brief for Claude Fable
## Production-Ready App Development Specification

**Prepared for:** Claude Fable 5  
**Project:** StoryForce — B2B Sales Storyselling Mobile App  
**Status:** APPROVED FOR IMMEDIATE DEVELOPMENT  
**Target Launch:** 8 weeks from start  
**Budget:** $40K–$52K development costs (staffing)

---

## PROJECT OVERVIEW (60 seconds)

**What:** A mobile app that helps B2B sales reps (enterprise, consulting, financial services) generate AI-powered storytelling narratives to close more deals.

**How:** Rep describes a client → App uses Fable LLM to generate a research-backed Three-Act story → Rep practices with Google Gemini Voice as a skeptical client coach → Rep delivers story in real meeting.

**Why:** Sales professionals in high-stakes B2B need personalized, emotionally resonant narratives to build trust. Storyselling methodology is battle-tested (book + Babson course + Novartis enterprise implementation). Voice coaching is differentiated from competitors.

**Business Model:** Free for event attendees (viral seed); Professional tier $12.99/mo (unlimited stories + advanced coaching); Enterprise custom pricing.

**Success Target:** 500+ downloads, 50+ paying subscribers within 90 days.

---

## THE COMPLETE TECH STACK

| Layer | Technology | Purpose |
|-------|-----------|---------|
| **Mobile** | SwiftUI (iOS 15+) | Native iOS app, high performance |
| **LLM (Story)** | Claude Fable API | Three-Act story generation + refinement |
| **Voice Input/Output** | Google Gemini Voice API | Speech-to-text (client description) + text-to-speech (coaching) |
| **Backend API** | Node.js/Express or Python FastAPI | Route requests, manage voice processing |
| **Database** | PostgreSQL (RDS) + Redis cache | Persistent user data, story library, analytics |
| **Storage** | AWS S3 or GCP Cloud Storage | Audio recordings (auto-delete after 90 days) |
| **Auth** | Firebase Auth or Auth0 + JWT | User authentication, subscription tier gating |
| **Deployment** | Docker + AWS ECS/Fargate or GCP Cloud Run | Containerized backend, auto-scaling |
| **CDN** | AWS CloudFront or Cloudflare | Static assets, fast delivery globally |

**Total Monthly Infrastructure Cost:** ~$700 (scales to <$2K at 10K users)

---

## CRITICAL SUCCESS FACTORS (READ THIS FIRST)

1. **Voice-First Experience:** Voice input/output is PRIMARY, not secondary. If voice breaks, app value collapses. Test aggressively on real devices with real accents, background noise, etc.

2. **Low Latency is Non-Negotiable:** 
   - Speech-to-text: <1 sec response
   - Coaching feedback: <2 sec response
   - Full practice loop: <5 sec
   - If latency >3 sec, user experience feels broken.

3. **Fable Must Be Used Wisely:**
   - Use for Three-Act story generation (core)
   - Use for delivery analysis (is story following 3-act structure?)
   - Do NOT use Fable for real-time chat (cost + latency prohibitive)
   - Gemini Voice is lighter-weight for dialogue and speech-to-text

4. **Data Privacy:**
   - Audio recordings must be deleted after 90 days (GDPR/CCPA compliant)
   - Users must be able to manually delete recordings
   - Enterprise customers may require on-prem audio storage (design for it)

5. **Subscription Tier Gating is Revenue-Critical:**
   - Free: 5 stories/month, basic feedback only
   - Professional: Unlimited, full voice coaching
   - Enterprise: Custom, team collaboration, CRM integrations
   - Implement subscription checks on every API call

---

## THE PRODUCT: THREE-ACT STORY ENGINE

### Core Loop (What Users Do Daily)

```
1. Rep opens app (30 seconds to this point)
2. Taps "Describe a Client"
3. Speaks 2-3 minutes describing client situation
4. App (Gemini) asks 1-2 clarifying questions via voice
5. Rep answers
6. App shows extracted client profile (Winter + Spring states)
7. Rep taps "Generate Story"
8. Fable generates Three-Act story (30 seconds)
9. Rep reads/listens to story on screen
10. Rep taps "Practice"
11. Rep speaks the story aloud
12. Gemini transcribes, Fable analyzes delivery quality
13. Gemini gives voice coaching feedback
14. Rep can try again or save
15. Story saved to library with scores + metrics
16. Next rep uses app again for next client meeting
```

**Time-to-Delivery:** 90 seconds (client description) + 3 minutes (practice) = ~5 min total.

### Three-Act Structure (What Gets Generated)

```
ACT 1: THE HOOK (45 seconds)
- "I see your fear"
- Show understanding of their "Winter" state
- Build psychological safety

ACT 2: THE BRIDGE (2 minutes)
- Story about similar client (from case study library)
- How they moved from Winter to Spring
- Specific results + emotional outcome

ACT 3: THE PAYOFF (60 seconds)
- Paint vivid picture of client's "Spring"
- Emotional, tangible outcome
- Natural transition to next steps
```

**Prompt Template:** See StoryForce_Technical_Architecture_Blueprint.md, Section 5

---

## THE MVP FEATURE SET (Anything else = Phase 2)

### MUST-BUILD (Phase 1, weeks 1–8)
1. ✅ Client Profile Analyzer (voice/text input)
2. ✅ Three-Act Story Generator (Fable LLM)
3. ✅ Metaphor Engine (generate 3–5 relevant metaphors)
4. ✅ Practice Coach with Voice (Gemini + Fable analysis)
5. ✅ Story Library (save, view, search)
6. ✅ Meeting Outcome Tracking (did rep win/lose?)
7. ✅ Basic Analytics Dashboard (stories/month, conversion rate)
8. ✅ Authentication (sign-up, login, subscription gating)

### SHOULD-BUILD (Phase 1, if time permits)
- Story export to PDF for sharing
- Team admin features (view team stats)
- Gemini real-time dialogue (client profile clarification)

### DO NOT BUILD (Phase 2+)
- CRM integrations (Salesforce, HubSpot)
- Video coaching
- AR body language feedback
- White-label/enterprise portal
- Predictive models (which stories convert best)

---

## THE DATA MODELS (Quick Reference)

### User
```json
{
  "id": "uuid",
  "email": "rep@company.com",
  "subscriptionTier": "free | professional | team | enterprise",
  "storiesGeneratedThisMonth": 12,
  "practiceSessionsThisMonth": 8,
  "createdAt": "2026-06-15"
}
```

### ClientProfile
```json
{
  "id": "uuid",
  "clientName": "Mike Johnson",
  "industry": "pharmaceutical",
  "currentWinter": {
    "primaryFear": "Cost containment + operational disruption",
    "painPoints": ["Budget cuts", "Legacy systems"]
  },
  "desiredSpring": {
    "mainGoal": "20% cost reduction without service disruption",
    "emotionalOutcome": "Confidence, control, legacy preservation"
  }
}
```

### Story
```json
{
  "id": "uuid",
  "threeActStructure": {
    "act1_hook": "I see your fear...",
    "act2_bridge": "I had a client named Sarah...",
    "act3_payoff": "Imagine next year..."
  },
  "metaphors": ["Like a gardener trimming branches..."],
  "practiceAttempts": [
    {
      "audio_url": "s3://...",
      "geminiAnalysis": {
        "paceScore": 8,
        "emotionalResonanceScore": 7,
        "overallScore": 7.5,
        "feedback": "Good structure, but rushed through Act 1"
      }
    }
  ],
  "meetingOutcome": {
    "result": "won",
    "dealValue": 250000,
    "clientFeedback": 9
  }
}
```

**Full schema:** See StoryForce_Technical_Architecture_Blueprint.md, Section 6

---

## THE API (13 Core Endpoints)

| Method | Endpoint | Purpose |
|--------|----------|---------|
| POST | /auth/signup | User registration |
| POST | /auth/login | User login (JWT) |
| POST | /api/client-profiles | Save client profile from voice/text |
| GET | /api/client-profiles/:id | Fetch profile |
| POST | /api/stories/generate | Call Fable to generate Three-Act story |
| GET | /api/stories/:id | Fetch story |
| POST | /api/stories/:id/practice | Send rep's audio, get Gemini + Fable analysis |
| GET | /api/stories?userId=X | Fetch user's story library |
| POST | /api/stories/:id/outcome | Record meeting result (won/lost/pending) |
| GET | /api/analytics/user/:id | Return user's stats (stories, scores, conversions) |
| DELETE | /api/stories/:id | Delete story (soft delete) |
| POST | /api/auth/refresh | Refresh JWT token |
| GET | /api/case-studies | Fetch case study library for Act 2 |

**Full spec:** See StoryForce_Technical_Architecture_Blueprint.md, Section 3

---

## THE SCREENS (12 Total)

**Priority build order:**
1. Onboarding (splash, welcome, auth, permissions) — Week 1–2
2. Dashboard (home, stats, quick action) — Week 2
3. Describe Client (voice input, clarification) — Week 2–3
4. Story Display (Three-Act with metaphors) — Week 3
5. Practice Coach (voice recording, feedback) — Week 4–5
6. Story Library (history, analytics) — Week 5
7. Settings (account, subscription, privacy) — Week 6
8. Error states & edge cases — Week 6–7
9. Testing & optimization — Week 7–8

**Wireframes:** See StoryForce_UI_UX_Design_System.md, Section 4

**Component library:** See StoryForce_UI_UX_Design_System.md, Section 5

---

## THE VOICE INTEGRATION (Critical)

### Speech-to-Text (Client Description)
```
User speaks → iOS captures audio via AVAudioEngine
    → Sends to /api/profiles/from-voice endpoint
    → Backend calls Google Gemini Voice API (speech-to-text)
    → Fable NLP extracts: name, role, company, fears, goals
    → Returns structured ClientProfile JSON
    → iOS displays profile for confirmation
```

### Text-to-Speech (Coaching Feedback)
```
Fable analyzes rep's delivery → Generates feedback text
    → Backend calls Google Gemini Voice API (text-to-speech)
    → Returns audio stream
    → iOS plays audio with AVAudioEngine
    → Rep hears: "Great pace, but pause here"
```

### Real-Time Conversation (Clarifying Questions)
```
Rep speaks description → Gemini transcribes
    → Extracts profile, identifies missing info
    → Generates 1–2 clarifying questions
    → Text-to-speech reads questions back
    → Rep answers
    → Loop repeats until profile complete
```

**Latency Targets:**
- Speech-to-text: <1 sec
- Feedback TTS: <2 sec  
- Full loop: <5 sec

**Error Handling:**
- If Gemini API down: Fall back to text-based input
- If audio quality poor: Prompt user to move to quiet location
- If timeout: Auto-save and allow retry

---

## THE COST MODEL (What Fable Needs to Optimize For)

### API Costs (Per Story)
| Service | Per Story | Cost |
|---------|-----------|------|
| Fable story generation (~500 tokens) | 1x | ~$0.002 |
| Gemini speech-to-text (1 min) | 1x | ~$0.001 |
| Gemini text-to-speech feedback (30 sec) | 1x | ~$0.0005 |
| **Total per story** | | **~$0.0035** |

At 100K stories/month: ~$350/month in API costs.
At $12.99/mo subscription, 50+ paying users break even easily.

### Infrastructure Cost (Monthly)
- RDS PostgreSQL: $30
- S3 storage (500GB): $12
- CloudFront CDN: $85
- EC2/Fargate compute: $150
- Redis cache: $20
- Monitoring: $50
- **Total: ~$350/month**

At scale (10K users): Still <$2K/month infrastructure + API costs.

**Gross margin:** 95%+ (subscription revenue vs. COGS)

---

## THE DEVELOPMENT TIMELINE (8 Weeks)

### Week 1–2: Infrastructure & Auth
- [ ] PostgreSQL schema (users, client_profiles, stories, practice_attempts, outcomes)
- [ ] Firebase Auth integration
- [ ] JWT token generation & validation
- [ ] API gateway + rate limiting
- [ ] Basic error handling middleware

### Week 3–4: Core Fable Integration
- [ ] Story generation endpoint (/api/stories/generate)
- [ ] Fable API client setup
- [ ] Three-Act prompt template validation
- [ ] Metaphor generation
- [ ] Test end-to-end story generation

### Week 5–6: Gemini Voice Integration
- [ ] Speech-to-text pipeline (/api/profiles/from-voice)
- [ ] Client profile NLP extraction
- [ ] Text-to-speech for coaching feedback
- [ ] Practice coaching endpoint (/api/stories/:id/practice)
- [ ] Audio storage (S3) + auto-delete policy
- [ ] Latency optimization (target <2 sec)

### Week 7: iOS App (SwiftUI)
- [ ] Authentication screens (sign-up, login)
- [ ] Onboarding flow
- [ ] Dashboard (home screen)
- [ ] Client description (voice input)
- [ ] Story display (Three-Act)
- [ ] Practice screen (voice recording + playback)
- [ ] Story library
- [ ] Settings

### Week 8: Testing & Optimization
- [ ] End-to-end testing (all user flows)
- [ ] Voice quality testing (various accents, backgrounds)
- [ ] Performance optimization (latency, battery usage)
- [ ] Accessibility testing (VoiceOver, contrast ratios)
- [ ] App Store submission prep
- [ ] Bug fixes & final polish

**Deliverable:** Production-ready iOS app + backend API, ready for App Store submission.

---

## KEY DECISIONS FABLE NEEDS TO MAKE

1. **Backend Language:** Node.js/Express (faster iteration) or Python FastAPI (better ML integration)?
   - **Recommendation:** Node.js for speed, Python for future AI features

2. **Database:** PostgreSQL (we recommend this). Other options: MongoDB (not ideal for structured data).

3. **Hosting:** AWS vs. GCP?
   - **Recommendation:** AWS (better Fable API support, better pricing for RDS)

4. **Audio Storage:** S3 vs. GCP Cloud Storage?
   - **Recommendation:** S3 (simpler, better with AWS stack)

5. **Voice Quality Threshold:** How high do latency targets need to be to ship?
   - **Recommendation:** Ship with <2 sec latency, optimize post-launch

---

## TESTING CHECKLIST (Before App Store Submission)

### Functional Testing
- [ ] All screens render correctly (light + dark mode)
- [ ] Voice recording works on physical devices (iPhone 12+)
- [ ] Speech-to-text produces accurate transcriptions (5+ test cases)
- [ ] Fable story generation produces valid Three-Act structure
- [ ] Gemini coaching feedback is coherent and actionable
- [ ] Subscription tier gating works (free users capped at 5/month)
- [ ] Story analytics update correctly after meeting outcome
- [ ] Audio files auto-delete after 90 days

### Performance Testing
- [ ] Story generation: <5 sec (cached, optimal)
- [ ] Coaching feedback: <3 sec
- [ ] App launch: <2 sec
- [ ] Story library load (50+ stories): <2 sec
- [ ] Voice recording quality: works in noisy environments (car, coffee shop)

### Accessibility Testing
- [ ] VoiceOver: All interactive elements navigable + labeled
- [ ] Contrast: All text meets WCAG AA (4.5:1 minimum)
- [ ] Touch targets: All buttons ≥44x44 pt
- [ ] No color-only indicators (red = recording; also use pulsing animation)

### Security Testing
- [ ] JWT tokens expire after 24 hours
- [ ] Refresh token works correctly
- [ ] API rate limiting prevents brute force
- [ ] Audio data encrypted in transit (HTTPS) + at rest (S3 encryption)
- [ ] No sensitive data in logs
- [ ] GDPR: Users can delete all data

### Voice Testing
- [ ] Test with: American, British, Indian, Chinese accents
- [ ] Test in: Quiet office, busy coffee shop, moving car
- [ ] Test with: Professional tone, casual tone, emotional tone
- [ ] Edge cases: Very fast speaker, very slow speaker, stuttering

---

## GO-TO-MARKET (Week 9+, Not Fable's responsibility, but context)

**Launch Event:** Babson Summer Course (July 27–31, 2026)  
**Free seeding:** All event attendees get free Professional tier access  
**Paid conversion:** Upsell via email → Subscribe for continued access  
**Viral hook:** "I used this app to close a $500K deal"

**Target metrics (90 days post-launch):**
- 500+ downloads
- 50+ paying subscribers ($12.99/mo)
- 70%+ self-reported deal win rate (survey)
- 8+ NPS score

---

## REFERENCE DOCUMENTS

You have **three complete specification documents** in your Sandbox folder:

1. **StoryForce_Technical_Architecture_Blueprint.md** (13K words)
   - System design, API spec, database schema, deployment strategy
   - Read this if you have architecture questions

2. **StoryForce_UI_UX_Design_System.md** (8K words)
   - Screen layouts, component library, accessibility guidelines
   - Read this if you have UI/UX questions

3. **This document** (executive brief)
   - Quick reference, timeline, key decisions
   - Read this first

---

## FINAL NOTES

- **You have everything you need to build this.** No ambiguity, no back-and-forth needed.
- **The market wants this.** Storyselling methodology is proven (book + Babson + Novartis). Voice coaching is differentiated.
- **The timeline is tight but achievable.** 8 weeks from start to App Store submission.
- **This is revenue-positive from day 1.** At $12.99/mo with 50 subscribers, you're generating $650/mo with $350 COGS.
- **Ship the MVP first.** Don't gold-plate. Iterate post-launch.

---

## APPROVAL & SIGN-OFF

✅ **Product Concept:** Approved  
✅ **Technical Architecture:** Approved  
✅ **UI/UX Design:** Approved  
✅ **Business Model:** Approved  
✅ **Timeline:** Approved  

**Status: READY FOR IMMEDIATE DEVELOPMENT**

**Next Step:** Fable starts backend development (Week 1, infrastructure + auth)

---

*Handoff brief prepared for Claude Fable*  
*All supporting documentation complete*  
*Launch target: 8 weeks*  
*July 2, 2026*
