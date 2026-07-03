/**
 * Fable LLM Client
 * Wrapper for Claude Fable API for Three-Act story generation
 * Includes retry logic, timeout handling, cost tracking
 */

const axios = require('axios');
const { CostTracker } = require('./costTracker');

class FableClient {
  constructor() {
    this.apiKey = process.env.FABLE_API_KEY;
    this.model = process.env.FABLE_MODEL || 'claude-fable-5';
    this.baseUrl = 'https://api.anthropic.com/v1';
    this.maxRetries = 3;
    this.retryDelay = 1000; // ms
    this.timeout = 30000; // 30 seconds
    this.costTracker = new CostTracker();

    if (!this.apiKey) {
      throw new Error('FABLE_API_KEY environment variable not set');
    }
  }

  /**
   * Generate Three-Act story using Fable LLM
   * @param {Object} clientProfile - Client profile with winter/spring state
   * @returns {Promise<Object>} Story with act1, act2, act3, metaphors, guidance
   */
  async generateStory(clientProfile) {
    const prompt = this._buildPrompt(clientProfile);

    try {
      const response = await this._callFableWithRetry(prompt);
      const story = this._parseResponse(response);

      // Track cost
      await this.costTracker.trackUsage({
        model: this.model,
        inputTokens: response.usage?.input_tokens || 0,
        outputTokens: response.usage?.output_tokens || 0,
        cost: response.cost || 0,
      });

      return {
        success: true,
        story,
        cost: response.cost || 0,
        timestamp: new Date().toISOString(),
      };
    } catch (error) {
      console.error('Fable story generation failed:', error);

      // Fall back to template story if LLM fails
      return {
        success: false,
        story: this._getTemplateStory(clientProfile),
        error: error.message,
        fallback: true,
        timestamp: new Date().toISOString(),
      };
    }
  }

  /**
   * Internal: Build Three-Act prompt from client profile
   */
  _buildPrompt(profile) {
    return `You are an expert sales storyteller. Generate a powerful Three-Act story for this client scenario.

CLIENT PROFILE:
Name: ${profile.client_name}
Role: ${profile.client_role || 'Unknown'}
Company: ${profile.company}
Industry: ${profile.industry || 'Unknown'}

CURRENT STATE (Winter - Pain & Fear):
${JSON.stringify(profile.winter_json, null, 2)}

DESIRED STATE (Spring - Vision & Outcome):
${JSON.stringify(profile.spring_json, null, 2)}

TASK: Generate a compelling Three-Act story that moves the client from Winter to Spring.

ACT 1 - THE HOOK (45 seconds):
- Show you deeply understand their pain and fear
- Make them feel heard and validated
- End with intrigue/curiosity

ACT 2 - THE BRIDGE (2 minutes):
- Tell a specific, relatable story about a similar client who succeeded
- Include concrete details and challenges they faced
- Show how they overcame obstacles
- Make it emotionally resonant

ACT 3 - THE PAYOFF (60 seconds):
- Paint a vivid picture of their Spring state
- Show the transformation that's possible
- Make them feel the positive emotions of success
- End with a clear call to action

Additional Requirements:
- Create 3-4 powerful metaphors they can use in conversation
- Provide delivery guidance (pace, tone, pauses, emotional beats)
- Ensure the story is authentic and not overly salesy

RESPONSE FORMAT (JSON):
{
  "act1Hook": "...",
  "act2Bridge": "...",
  "act3Payoff": "...",
  "metaphors": ["...", "...", "..."],
  "deliveryGuidance": {
    "pace": "...",
    "tone": "...",
    "pauses": [{"after": "Act 1 ending", "duration": "2-3 seconds"}],
    "emotionalBeats": ["...", "..."]
  },
  "tipsForRep": "..."
}`;
  }

  /**
   * Internal: Call Fable API with exponential backoff retry
   */
  async _callFableWithRetry(prompt) {
    let lastError;

    for (let attempt = 0; attempt < this.maxRetries; attempt++) {
      try {
        const response = await axios.post(
          `${this.baseUrl}/messages`,
          {
            model: this.model,
            max_tokens: 2000,
            messages: [
              {
                role: 'user',
                content: prompt,
              },
            ],
          },
          {
            headers: {
              'x-api-key': this.apiKey,
              'anthropic-version': '2023-06-01',
              'content-type': 'application/json',
            },
            timeout: this.timeout,
          }
        );

        // Extract cost from response
        const inputTokens = response.data.usage?.input_tokens || 0;
        const outputTokens = response.data.usage?.output_tokens || 0;
        const inputCost = (inputTokens / 1_000_000) * 3; // $3 per 1M input tokens
        const outputCost = (outputTokens / 1_000_000) * 15; // $15 per 1M output tokens
        const totalCost = inputCost + outputCost;

        return {
          ...response.data,
          cost: totalCost,
          usage: {
            input_tokens: inputTokens,
            output_tokens: outputTokens,
          },
        };
      } catch (error) {
        lastError = error;
        const delayMs = this.retryDelay * Math.pow(2, attempt);

        console.warn(
          `Fable API attempt ${attempt + 1}/${this.maxRetries} failed. ` +
          `Retrying in ${delayMs}ms...`,
          error.message
        );

        if (attempt < this.maxRetries - 1) {
          await new Promise(resolve => setTimeout(resolve, delayMs));
        }
      }
    }

    throw new Error(
      `Fable API failed after ${this.maxRetries} retries: ${lastError.message}`
    );
  }

  /**
   * Internal: Parse Fable response and extract story
   */
  _parseResponse(response) {
    try {
      const content = response.content[0]?.text || '';

      // Extract JSON from response (Fable might include extra text)
      const jsonMatch = content.match(/\{[\s\S]*\}/);
      if (!jsonMatch) {
        throw new Error('No JSON found in response');
      }

      const story = JSON.parse(jsonMatch[0]);

      // Validate required fields
      if (!story.act1Hook || !story.act2Bridge || !story.act3Payoff) {
        throw new Error('Missing required story acts');
      }

      return {
        act1Hook: story.act1Hook,
        act2Bridge: story.act2Bridge,
        act3Payoff: story.act3Payoff,
        metaphors: story.metaphors || [],
        deliveryGuidance: story.deliveryGuidance || {},
        tipsForRep: story.tipsForRep || '',
      };
    } catch (error) {
      console.error('Failed to parse Fable response:', error);
      throw error;
    }
  }

  /**
   * Internal: Fallback template story if LLM fails
   */
  _getTemplateStory(profile) {
    return {
      act1Hook: `I understand ${profile.client_name} at ${profile.company} faces real challenges around ${profile.winter_json?.pain || 'their business goals'}. That's exactly what we help solve.`,
      act2Bridge: `I worked with a similar company in ${profile.industry || 'your industry'} who felt the same way. They were losing deals, struggling with consistency, and their team wasn't confident in their messaging. But when they changed their approach to storytelling, everything shifted. Deals started moving faster, and their reps felt empowered.`,
      act3Payoff: `I see ${profile.client_name} achieving ${profile.spring_json?.vision || 'their goals'} through authentic, powerful storytelling. Your team will feel confident, prospects will feel heard, and your deals will advance naturally.`,
      metaphors: [
        'Like building a bridge from their current pain to their desired future',
        'Similar to planting seeds that grow into lasting client relationships',
      ],
      deliveryGuidance: {
        pace: 'Slow and deliberate - let each act breathe',
        tone: 'Warm, authentic, conversational',
        pauses: [
          { after: 'Act 1 Hook', duration: '2-3 seconds' },
          { after: 'Act 2 Bridge', duration: '1-2 seconds' },
        ],
      },
      tipsForRep: 'Tell this story like you\'re talking to a friend, not pitching a prospect.',
    };
  }

  /**
   * Health check - verify API connectivity
   */
  async healthCheck() {
    try {
      const response = await axios.post(
        `${this.baseUrl}/messages`,
        {
          model: this.model,
          max_tokens: 10,
          messages: [{ role: 'user', content: 'Hello' }],
        },
        {
          headers: {
            'x-api-key': this.apiKey,
            'anthropic-version': '2023-06-01',
          },
          timeout: 5000,
        }
      );

      return {
        status: 'healthy',
        model: this.model,
        timestamp: new Date().toISOString(),
      };
    } catch (error) {
      return {
        status: 'unhealthy',
        error: error.message,
        timestamp: new Date().toISOString(),
      };
    }
  }
}

module.exports = { FableClient };
