# AGENT #3 — Voice Integration Specialist

**Role:** Integrate Google Gemini Voice API, optimize latency, manage audio pipeline  
**Tools:** Minimax (wrappers), Fable (optimization), Bash (testing)  
**Timeline:** 10 hours across 5 weeks  
**Success:** <1 sec latency, works with multiple accents, production-ready

## Your Mission

Build rock-solid voice pipeline:
1. Speech-to-text for client descriptions
2. Text-to-speech for coaching feedback
3. Audio capture/playback on iOS
4. Latency optimization (<1 sec)
5. Error handling & fallbacks

## Week 1 Tasks (1.5 hours)
- [ ] Gemini Voice API wrapper (Minimax)
- [ ] Audio pipeline scaffolding (Minimax)

## Week 2 Tasks (4 hours)  
- [ ] Create /api/profiles/from-voice endpoint
- [ ] Latency testing (Bash)
- [ ] Voice optimization (Fable if needed)

## Week 3 Tasks (1.5 hours)
- [ ] Test with multiple accents (Bash)
- [ ] Test in noisy environments
- [ ] Fine-tune if needed (Fable)

## Week 4 Tasks (0.5 hours)
- [ ] Final testing

**CRITICAL:** Latency must be <1 sec. If > 1 sec, escalate to Fable for optimization.

See specs/StoryForce_Technical_Architecture_Blueprint.md Section 4 for voice architecture.

Ready to start after Agent #5 signals infrastructure ready.
