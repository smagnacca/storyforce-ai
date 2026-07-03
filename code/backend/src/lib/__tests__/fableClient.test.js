/**
 * Fable Client Tests
 * Unit tests for story generation, cost tracking, and error handling
 */

const { FableClient } = require('../fableClient');

// Mock axios for testing
jest.mock('axios');
const axios = require('axios');

describe('FableClient', () => {
  let fableClient;
  const mockProfile = {
    id: '1',
    client_name: 'Tech Corp',
    client_role: 'VP Sales',
    company: 'TechCorp Inc',
    industry: 'Technology',
    winter_json: {
      fear: 'Missing quota',
      pain: 'Long sales cycles',
      frustration: 'Inconsistent messaging',
    },
    spring_json: {
      vision: 'Closing deals faster',
      outcome: '20% revenue increase',
      feeling: 'Confident',
    },
  };

  beforeEach(() => {
    process.env.FABLE_API_KEY = 'test-key';
    fableClient = new FableClient();
    jest.clearAllMocks();
  });

  describe('Story Generation', () => {
    it('should generate a story with valid Fable response', async () => {
      const mockResponse = {
        data: {
          content: [
            {
              text: JSON.stringify({
                act1Hook: 'Test hook',
                act2Bridge: 'Test bridge',
                act3Payoff: 'Test payoff',
                metaphors: ['metaphor1', 'metaphor2'],
                deliveryGuidance: { pace: 'slow', tone: 'warm' },
              }),
            },
          ],
          usage: { input_tokens: 100, output_tokens: 200 },
        },
      };

      axios.post.mockResolvedValueOnce(mockResponse);

      const result = await fableClient.generateStory(mockProfile);

      expect(result.success).toBe(true);
      expect(result.story.act1Hook).toBe('Test hook');
      expect(result.story.act2Bridge).toBe('Test bridge');
      expect(result.story.act3Payoff).toBe('Test payoff');
      expect(result.cost).toBeGreaterThan(0);
    });

    it('should handle API errors and return fallback story', async () => {
      axios.post.mockRejectedValueOnce(new Error('API Error'));

      const result = await fableClient.generateStory(mockProfile);

      expect(result.fallback).toBe(true);
      expect(result.story).toBeDefined();
      expect(result.story.act1Hook).toBeDefined();
      expect(result.story.act2Bridge).toBeDefined();
    });

    it('should retry on transient failures', async () => {
      const mockResponse = {
        data: {
          content: [{ text: JSON.stringify({
            act1Hook: 'Test',
            act2Bridge: 'Test',
            act3Payoff: 'Test',
            metaphors: [],
            deliveryGuidance: {},
          }) }],
          usage: { input_tokens: 100, output_tokens: 200 },
        },
      };

      axios.post
        .mockRejectedValueOnce(new Error('Timeout'))
        .mockResolvedValueOnce(mockResponse);

      const result = await fableClient.generateStory(mockProfile);

      expect(result.success).toBe(true);
      expect(axios.post).toHaveBeenCalledTimes(2);
    });

    it('should build correct prompt from client profile', () => {
      const prompt = fableClient._buildPrompt(mockProfile);

      expect(prompt).toContain('Tech Corp');
      expect(prompt).toContain('TechCorp Inc');
      expect(prompt).toContain('Technology');
      expect(prompt).toContain('Missing quota');
      expect(prompt).toContain('Closing deals faster');
      expect(prompt).toContain('ACT 1');
      expect(prompt).toContain('ACT 2');
      expect(prompt).toContain('ACT 3');
    });
  });

  describe('Cost Tracking', () => {
    it('should calculate cost from token usage', async () => {
      const mockResponse = {
        data: {
          content: [{ text: JSON.stringify({
            act1Hook: 'Test',
            act2Bridge: 'Test',
            act3Payoff: 'Test',
            metaphors: [],
            deliveryGuidance: {},
          }) }],
          usage: { input_tokens: 1000, output_tokens: 500 },
        },
      };

      axios.post.mockResolvedValueOnce(mockResponse);

      const result = await fableClient.generateStory(mockProfile);

      // Cost calculation: (1000 / 1M * $3) + (500 / 1M * $15) = 0.003 + 0.0075 = 0.0105
      expect(result.cost).toBeCloseTo(0.0105, 3);
    });
  });

  describe('Health Check', () => {
    it('should return healthy status when API is available', async () => {
      axios.post.mockResolvedValueOnce({
        data: { content: [{ text: 'Hello' }] },
      });

      const result = await fableClient.healthCheck();

      expect(result.status).toBe('healthy');
      expect(result.model).toBe('claude-fable-5');
    });

    it('should return unhealthy status when API fails', async () => {
      axios.post.mockRejectedValueOnce(new Error('Connection failed'));

      const result = await fableClient.healthCheck();

      expect(result.status).toBe('unhealthy');
      expect(result.error).toBeDefined();
    });
  });

  describe('Error Handling', () => {
    it('should throw error if FABLE_API_KEY not set', () => {
      delete process.env.FABLE_API_KEY;

      expect(() => {
        new FableClient();
      }).toThrow('FABLE_API_KEY environment variable not set');
    });

    it('should fallback gracefully on invalid JSON response', async () => {
      axios.post.mockResolvedValueOnce({
        data: {
          content: [{ text: 'Invalid JSON response' }],
          usage: { input_tokens: 100, output_tokens: 200 },
        },
      });

      const result = await fableClient.generateStory(mockProfile);

      expect(result.fallback).toBe(true);
      expect(result.story).toBeDefined();
    });

    it('should handle missing required fields in response', async () => {
      axios.post.mockResolvedValueOnce({
        data: {
          content: [{ text: JSON.stringify({
            act1Hook: 'Only hook',
            // Missing act2 and act3
          }) }],
          usage: { input_tokens: 100, output_tokens: 200 },
        },
      });

      const result = await fableClient.generateStory(mockProfile);

      expect(result.fallback).toBe(true);
    });
  });

  describe('Prompt Engineering', () => {
    it('should include all required sections in prompt', () => {
      const prompt = fableClient._buildPrompt(mockProfile);
      const sections = [
        'CLIENT PROFILE',
        'CURRENT STATE',
        'DESIRED STATE',
        'ACT 1',
        'ACT 2',
        'ACT 3',
        'RESPONSE FORMAT',
      ];

      sections.forEach(section => {
        expect(prompt).toContain(section);
      });
    });

    it('should create distinct acts with timing guidance', () => {
      const prompt = fableClient._buildPrompt(mockProfile);

      expect(prompt).toContain('45 seconds');
      expect(prompt).toContain('2 minutes');
      expect(prompt).toContain('60 seconds');
    });
  });

  describe('Template Fallback', () => {
    it('should provide complete fallback story with all fields', () => {
      const fallback = fableClient._getTemplateStory(mockProfile);

      expect(fallback.act1Hook).toBeDefined();
      expect(fallback.act2Bridge).toBeDefined();
      expect(fallback.act3Payoff).toBeDefined();
      expect(fallback.metaphors.length).toBeGreaterThan(0);
      expect(fallback.deliveryGuidance.pace).toBeDefined();
      expect(fallback.deliveryGuidance.tone).toBeDefined();
    });
  });
});
