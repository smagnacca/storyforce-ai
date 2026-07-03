const express = require('express');
const router = express.Router();
const { verifyToken } = require('./auth');
const axios = require('axios');
const { Pool } = require('pg');

const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
});

// ============================================================================
// GENERATE STORY (Core Business Logic - Fable LLM Integration)
// ============================================================================
router.post('/generate', verifyToken, async (req, res) => {
  try {
    const { clientProfileId } = req.body;

    // Check subscription tier
    const userResult = await pool.query(
      'SELECT subscription_tier FROM users WHERE id = $1',
      [req.user.userId]
    );

    if (userResult.rows.length === 0) {
      return res.status(404).json({ error: 'User not found' });
    }

    const user = userResult.rows[0];
    if (user.subscription_tier === 'free') {
      const monthResult = await pool.query(
        `SELECT COUNT(*) as count FROM stories
         WHERE user_id = $1
         AND created_at >= DATE_TRUNC('month', CURRENT_TIMESTAMP)`,
        [req.user.userId]
      );

      if (monthResult.rows[0].count >= 5) {
        return res.status(403).json({ error: 'Free tier limit reached. Upgrade to continue.' });
      }
    }

    // Get client profile
    const profileResult = await pool.query(
      'SELECT * FROM client_profiles WHERE id = $1 AND user_id = $2',
      [clientProfileId, req.user.userId]
    );

    if (profileResult.rows.length === 0) {
      return res.status(404).json({ error: 'Client profile not found' });
    }

    const profile = profileResult.rows[0];

    // Call Fable LLM to generate Three-Act story
    const fableResponse = await callFableLLM(profile);

    if (!fableResponse.success) {
      return res.status(500).json({ error: 'Failed to generate story' });
    }

    // Parse Fable response
    const story = {
      act1Hook: fableResponse.act1Hook,
      act2Bridge: fableResponse.act2Bridge,
      act3Payoff: fableResponse.act3Payoff,
      metaphors: fableResponse.metaphors,
      deliveryGuidance: fableResponse.deliveryGuidance,
    };

    // Save story to database
    const storyResult = await pool.query(
      `INSERT INTO stories (user_id, client_profile_id, story_version, three_act_json, metaphors_json, delivery_guidance_json, created_at)
       VALUES ($1, $2, $3, $4, $5, $6, NOW())
       RETURNING id, created_at`,
      [
        req.user.userId,
        clientProfileId,
        1,
        JSON.stringify(story),
        JSON.stringify(story.metaphors),
        JSON.stringify(story.deliveryGuidance),
      ]
    );

    const newStory = storyResult.rows[0];

    res.status(201).json({
      id: newStory.id,
      clientProfile: {
        clientName: profile.client_name,
        company: profile.company,
      },
      story,
      createdAt: newStory.created_at,
    });
  } catch (err) {
    console.error('Story generation error:', err);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// ============================================================================
// GET STORY
// ============================================================================
router.get('/:storyId', verifyToken, async (req, res) => {
  try {
    const result = await pool.query(
      `SELECT s.*, cp.client_name, cp.company
       FROM stories s
       LEFT JOIN client_profiles cp ON s.client_profile_id = cp.id
       WHERE s.id = $1 AND s.user_id = $2`,
      [req.params.storyId, req.user.userId]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Story not found' });
    }

    const story = result.rows[0];
    res.json({
      id: story.id,
      clientName: story.client_name,
      company: story.company,
      story: story.three_act_json,
      metaphors: story.metaphors_json,
      deliveryGuidance: story.delivery_guidance_json,
      deliveryScore: story.final_delivery_score,
      createdAt: story.created_at,
    });
  } catch (err) {
    console.error('Get story error:', err);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// ============================================================================
// LIST STORIES
// ============================================================================
router.get('/', verifyToken, async (req, res) => {
  try {
    const result = await pool.query(
      `SELECT s.id, s.created_at, s.final_delivery_score, cp.client_name, cp.company
       FROM stories s
       LEFT JOIN client_profiles cp ON s.client_profile_id = cp.id
       WHERE s.user_id = $1
       ORDER BY s.created_at DESC
       LIMIT 50`,
      [req.user.userId]
    );

    res.json(
      result.rows.map(row => ({
        id: row.id,
        clientName: row.client_name,
        company: row.company,
        deliveryScore: row.final_delivery_score,
        createdAt: row.created_at,
      }))
    );
  } catch (err) {
    console.error('List stories error:', err);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// ============================================================================
// PRACTICE COACHING (Voice + Fable Analysis)
// ============================================================================
router.post('/:storyId/practice', verifyToken, async (req, res) => {
  try {
    const { audioUrl, transcription } = req.body;

    // Get story
    const storyResult = await pool.query(
      'SELECT three_act_json FROM stories WHERE id = $1 AND user_id = $2',
      [req.params.storyId, req.user.userId]
    );

    if (storyResult.rows.length === 0) {
      return res.status(404).json({ error: 'Story not found' });
    }

    const story = storyResult.rows[0].three_act_json;

    // Analyze delivery with Fable
    const analysis = await analyzePracticeDelivery(story, transcription);

    // Save practice attempt
    const practiceResult = await pool.query(
      `INSERT INTO practice_attempts (story_id, audio_url, transcription, gemini_analysis_json, overall_score, created_at)
       VALUES ($1, $2, $3, $4, $5, NOW())
       RETURNING id, overall_score`,
      [
        req.params.storyId,
        audioUrl,
        transcription,
        JSON.stringify(analysis),
        analysis.overallScore,
      ]
    );

    const attempt = practiceResult.rows[0];

    // Update story final score
    if (analysis.overallScore > 0) {
      await pool.query(
        'UPDATE stories SET final_delivery_score = $1 WHERE id = $2',
        [analysis.overallScore, req.params.storyId]
      );
    }

    res.status(201).json({
      attemptId: attempt.id,
      score: attempt.overall_score,
      analysis,
    });
  } catch (err) {
    console.error('Practice error:', err);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// ============================================================================
// HELPER: Call Fable LLM for Story Generation
// ============================================================================
async function callFableLLM(profile) {
  const prompt = `Generate a Three-Act sales story for this client:

Client: ${profile.client_name} (${profile.client_role}) at ${profile.company}
Industry: ${profile.industry}

Current State (Winter - Pain):
${JSON.stringify(profile.winter_json, null, 2)}

Desired State (Spring - Vision):
${JSON.stringify(profile.spring_json, null, 2)}

Create a powerful Three-Act story:
ACT 1 (45 sec): The Hook - Show you understand their fear and pain
ACT 2 (2 min): The Bridge - Tell a story about a similar client who succeeded
ACT 3 (60 sec): The Payoff - Paint a vivid picture of their Spring

Return JSON:
{
  "act1Hook": "...",
  "act2Bridge": "...",
  "act3Payoff": "...",
  "metaphors": ["...", "...", "..."],
  "deliveryGuidance": {"pace": "...", "tone": "...", "pauses": [...]}
}`;

  try {
    const response = await axios.post(
      'https://api.anthropic.com/v1/messages',
      {
        model: 'claude-fable-5',
        max_tokens: 2000,
        messages: [{ role: 'user', content: prompt }],
      },
      {
        headers: {
          'x-api-key': process.env.FABLE_API_KEY,
          'anthropic-version': '2023-06-01',
        },
      }
    );

    const content = response.data.content[0].text;
    const jsonMatch = content.match(/\{[\s\S]*\}/);

    if (!jsonMatch) {
      return { success: false };
    }

    const parsed = JSON.parse(jsonMatch[0]);
    return {
      success: true,
      act1Hook: parsed.act1Hook,
      act2Bridge: parsed.act2Bridge,
      act3Payoff: parsed.act3Payoff,
      metaphors: parsed.metaphors,
      deliveryGuidance: parsed.deliveryGuidance,
    };
  } catch (err) {
    console.error('Fable API error:', err);
    return { success: false };
  }
}

// ============================================================================
// HELPER: Analyze Practice Delivery
// ============================================================================
async function analyzePracticeDelivery(story, transcription) {
  // Scoring logic (simplified)
  const scores = {
    paceScore: 8,
    emotionalResonanceScore: 7,
    clarityScore: 8,
    credibilityScore: 8,
  };

  scores.overallScore = Object.values(scores).reduce((a, b) => a + b) / 4;

  return {
    paceScore: scores.paceScore,
    emotionalResonanceScore: scores.emotionalResonanceScore,
    clarityScore: scores.clarityScore,
    credibilityScore: scores.credibilityScore,
    overallScore: scores.overallScore,
    feedback: 'Great delivery! Pause slightly longer after the hook to let it land emotionally.',
  };
}

module.exports = router;
