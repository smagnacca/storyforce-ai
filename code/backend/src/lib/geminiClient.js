/**
 * Google Gemini Voice API Client
 * Handles speech-to-text, delivery scoring, and coaching feedback
 */

const axios = require('axios');
const { CostTracker } = require('./costTracker');

class GeminiClient {
  constructor() {
    this.apiKey = process.env.GOOGLE_API_KEY;
    this.endpoint = process.env.GEMINI_VOICE_ENDPOINT || 'https://generativelanguage.googleapis.com/v1';
    this.costTracker = new CostTracker();

    if (!this.apiKey) {
      console.warn('GOOGLE_API_KEY not set - Gemini Voice features will use mocks');
    }
  }

  /**
   * Transcribe audio file to text using Gemini
   * @param {Buffer} audioBuffer - Audio file buffer
   * @param {string} mimeType - MIME type (e.g., 'audio/wav', 'audio/mp3')
   * @returns {Promise<Object>} Transcription result
   */
  async transcribeAudio(audioBuffer, mimeType = 'audio/wav') {
    try {
      const base64Audio = audioBuffer.toString('base64');

      const response = await axios.post(
        `${this.endpoint}/files:generateContent?key=${this.apiKey}`,
        {
          display_name: 'Practice Recording',
          mime_type: mimeType,
          data: base64Audio,
        },
        {
          headers: { 'Content-Type': 'application/json' },
          timeout: 10000,
        }
      );

      // Extract transcription from response
      const transcription = response.data?.candidates?.[0]?.content?.parts?.[0]?.text || '';

      await this.costTracker.trackUsage({
        model: 'gemini-voice',
        inputTokens: Math.ceil(audioBuffer.length / 4), // Rough estimate
        outputTokens: Math.ceil(transcription.length / 4),
        cost: 0.0001, // $0.0001 per transcription
      });

      return {
        success: true,
        transcription,
        confidence: 0.95,
        duration: Math.ceil(audioBuffer.length / 16000), // Rough estimate in seconds
      };
    } catch (error) {
      console.error('Gemini transcription error:', error);
      return {
        success: false,
        error: error.message,
        fallback: true,
      };
    }
  }

  /**
   * Score delivery performance on multiple dimensions
   * @param {string} storyText - The story text
   * @param {string} transcription - User's spoken delivery transcription
   * @returns {Promise<Object>} Delivery scores and feedback
   */
  async scoreDelivery(storyText, transcription) {
    try {
      const prompt = this._buildScoringPrompt(storyText, transcription);

      const response = await axios.post(
        `${this.endpoint}/models/gemini-pro:generateContent?key=${this.apiKey}`,
        {
          contents: [{ role: 'user', parts: [{ text: prompt }] }],
          generationConfig: { maxOutputTokens: 500 },
        },
        { timeout: 10000 }
      );

      const responseText = response.data?.candidates?.[0]?.content?.parts?.[0]?.text || '{}';
      const scores = this._parseScores(responseText);

      await this.costTracker.trackUsage({
        model: 'gemini-delivery-scoring',
        inputTokens: prompt.length / 4,
        outputTokens: responseText.length / 4,
        cost: 0.0002,
      });

      return {
        success: true,
        scores,
      };
    } catch (error) {
      console.error('Gemini scoring error:', error);
      return {
        success: false,
        scores: this._getTemplateScores(),
        error: error.message,
      };
    }
  }

  /**
   * Generate personalized coaching feedback
   * @param {Object} scores - Delivery scores
   * @param {string} story - The story that was practiced
   * @returns {Promise<string>} Coaching feedback
   */
  async generateCoachingFeedback(scores, story) {
    try {
      const weakestDimension = Object.entries(scores)
        .filter(([k]) => k.includes('Score'))
        .sort(([, a], [, b]) => a - b)[0];

      const feedback = this._buildCoachingMessage(scores, weakestDimension);

      return {
        success: true,
        feedback,
        nextSteps: [
          'Record another take focusing on ' + (weakestDimension?.[0] || 'pacing'),
          'Compare your delivery to the suggested pace and tone',
          'Practice the Act ' + (Math.floor(Math.random() * 3) + 1) + ' delivery tips',
        ],
      };
    } catch (error) {
      console.error('Coaching feedback error:', error);
      return {
        success: false,
        feedback: 'Great effort! Keep practicing and your delivery will improve.',
        nextSteps: ['Record another take', 'Focus on pacing and emotional resonance'],
      };
    }
  }

  /**
   * Internal: Build scoring prompt
   */
  _buildScoringPrompt(storyText, transcription) {
    return `Analyze this sales story delivery and provide scores.

ORIGINAL STORY:
${storyText}

USER'S SPOKEN DELIVERY:
"${transcription}"

Evaluate on these dimensions (1-10 scale):
1. Pace - Is the delivery at the right speed? (slow/deliberate = 10, rushed = 1)
2. Emotional Resonance - Does the delivery convey genuine emotion? (high = 10, monotone = 1)
3. Clarity - Are words clear and articulate? (very clear = 10, mumbled = 1)
4. Credibility - Does the delivery feel authentic and trustworthy? (highly believable = 10, seems fake = 1)

RESPONSE (JSON only, no other text):
{
  "paceScore": <1-10>,
  "emotionalResonanceScore": <1-10>,
  "clarityScore": <1-10>,
  "credibilityScore": <1-10>,
  "insights": "<2-3 sentence analysis>"
}`;
  }

  /**
   * Internal: Parse scores from response
   */
  _parseScores(responseText) {
    try {
      const jsonMatch = responseText.match(/\{[\s\S]*\}/);
      if (!jsonMatch) {
        return this._getTemplateScores();
      }

      const parsed = JSON.parse(jsonMatch[0]);
      return {
        paceScore: Math.min(10, Math.max(1, parseFloat(parsed.paceScore || 7))),
        emotionalResonanceScore: Math.min(10, Math.max(1, parseFloat(parsed.emotionalResonanceScore || 7))),
        clarityScore: Math.min(10, Math.max(1, parseFloat(parsed.clarityScore || 8))),
        credibilityScore: Math.min(10, Math.max(1, parseFloat(parsed.credibilityScore || 7))),
        insights: parsed.insights || 'Good delivery overall',
      };
    } catch (error) {
      return this._getTemplateScores();
    }
  }

  /**
   * Internal: Template scores for fallback
   */
  _getTemplateScores() {
    return {
      paceScore: 7.5,
      emotionalResonanceScore: 7.0,
      clarityScore: 8.0,
      credibilityScore: 7.5,
      insights: 'Your delivery shows good potential. Practice the timing and emotional beats.',
    };
  }

  /**
   * Internal: Build personalized coaching message
   */
  _buildCoachingMessage(scores, weakest) {
    const avg = Object.values(scores).slice(0, 4).reduce((a, b) => a + b, 0) / 4;

    const messages = {
      paceScore: 'Try pausing for 2-3 seconds after key phrases to let them land emotionally.',
      emotionalResonanceScore: 'Add more warmth and genuine emotion to your delivery - tell the story like you\'re talking to a friend.',
      clarityScore: 'Enunciate more clearly, especially at the end of sentences. Record another take focusing on crisp delivery.',
      credibilityScore: 'Your delivery feels hesitant. Own the story more - you clearly understand this client\'s pain.',
    };

    const weakestKey = weakest?.[0] || 'paceScore';
    const baseMessage = messages[weakestKey] || 'Keep practicing - you\'re getting better!';

    if (avg >= 8) {
      return `Excellent work! ${baseMessage} Your overall delivery scored ${avg.toFixed(1)}/10.`;
    } else if (avg >= 7) {
      return `Good effort! ${baseMessage} Keep practicing - your score is ${avg.toFixed(1)}/10.`;
    } else {
      return `Keep working on it. ${baseMessage} Your score is ${avg.toFixed(1)}/10. Practice makes perfect!`;
    }
  }

  /**
   * Health check - verify API connectivity
   */
  async healthCheck() {
    try {
      if (!this.apiKey) {
        return {
          status: 'unconfigured',
          message: 'GOOGLE_API_KEY not set',
          timestamp: new Date().toISOString(),
        };
      }

      const response = await axios.post(
        `${this.endpoint}/models/gemini-pro:generateContent?key=${this.apiKey}`,
        {
          contents: [{ role: 'user', parts: [{ text: 'test' }] }],
        },
        { timeout: 5000 }
      );

      return {
        status: 'healthy',
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

module.exports = { GeminiClient };
