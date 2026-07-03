/**
 * End-to-End Test Suite
 * Tests complete user flows: Auth → Story Generation → Practice → Analytics
 */

const request = require('supertest');
const { app } = require('../server');
const { Pool } = require('pg');

describe('StoryForce.AI E2E Tests', () => {
  let testUser;
  let authToken;
  let clientProfile;
  let generatedStory;

  const pool = new Pool({
    connectionString: process.env.DATABASE_URL,
  });

  beforeAll(async () => {
    // Setup: Ensure database is ready
    try {
      await pool.query('SELECT 1');
    } catch (error) {
      console.error('Database connection failed:', error);
      throw error;
    }
  });

  afterAll(async () => {
    await pool.end();
  });

  describe('1. Authentication Flow', () => {
    it('should signup new user', async () => {
      const res = await request(app).post('/api/auth/signup').send({
        email: 'e2e-test@example.com',
        password: 'TestPassword123!',
        firstName: 'E2E',
        lastName: 'Tester',
        company: 'Test Corp',
      });

      expect(res.statusCode).toBe(201);
      expect(res.body).toHaveProperty('token');
      expect(res.body.user).toHaveProperty('id');
      expect(res.body.user.email).toBe('e2e-test@example.com');

      testUser = res.body.user;
      authToken = res.body.token;
    });

    it('should login existing user', async () => {
      const res = await request(app).post('/api/auth/login').send({
        email: 'e2e-test@example.com',
        password: 'TestPassword123!',
      });

      expect(res.statusCode).toBe(200);
      expect(res.body).toHaveProperty('token');
      expect(res.body.user.id).toBe(testUser.id);
    });

    it('should retrieve authenticated user profile', async () => {
      const res = await request(app)
        .get('/api/auth/me')
        .set('Authorization', `Bearer ${authToken}`);

      expect(res.statusCode).toBe(200);
      expect(res.body.user.email).toBe('e2e-test@example.com');
    });

    it('should refresh JWT token', async () => {
      const res = await request(app)
        .post('/api/auth/refresh')
        .set('Authorization', `Bearer ${authToken}`);

      expect(res.statusCode).toBe(200);
      expect(res.body).toHaveProperty('token');
    });
  });

  describe('2. Client Profile Management', () => {
    it('should create client profile', async () => {
      const res = await request(app)
        .post('/api/profiles')
        .set('Authorization', `Bearer ${authToken}`)
        .send({
          clientName: 'John Smith',
          clientRole: 'VP Sales',
          company: 'TechCorp',
          industry: 'Technology',
          winterJson: {
            fear: 'Missing sales targets',
            pain: 'Long sales cycles',
            frustration: 'Inconsistent messaging',
          },
          springJson: {
            vision: 'Close deals faster',
            outcome: '20% revenue increase',
            feeling: 'Confident and aligned',
          },
        });

      expect(res.statusCode).toBe(201);
      expect(res.body).toHaveProperty('id');
      expect(res.body.clientName).toBe('John Smith');

      clientProfile = res.body;
    });

    it('should list client profiles', async () => {
      const res = await request(app)
        .get('/api/profiles')
        .set('Authorization', `Bearer ${authToken}`);

      expect(res.statusCode).toBe(200);
      expect(Array.isArray(res.body)).toBe(true);
      expect(res.body.length).toBeGreaterThan(0);
    });

    it('should get profile details', async () => {
      const res = await request(app)
        .get(`/api/profiles/${clientProfile.id}`)
        .set('Authorization', `Bearer ${authToken}`);

      expect(res.statusCode).toBe(200);
      expect(res.body.clientName).toBe('John Smith');
    });
  });

  describe('3. Story Generation', () => {
    it('should generate story with Fable LLM', async () => {
      const res = await request(app)
        .post('/api/stories/generate')
        .set('Authorization', `Bearer ${authToken}`)
        .send({
          clientProfileId: clientProfile.id,
        });

      expect(res.statusCode).toBe(201);
      expect(res.body).toHaveProperty('id');
      expect(res.body.story).toHaveProperty('act1Hook');
      expect(res.body.story).toHaveProperty('act2Bridge');
      expect(res.body.story).toHaveProperty('act3Payoff');
      expect(res.body.story.metaphors).toBeDefined();

      generatedStory = res.body;
    });

    it('should retrieve story details', async () => {
      const res = await request(app)
        .get(`/api/stories/${generatedStory.id}`)
        .set('Authorization', `Bearer ${authToken}`);

      expect(res.statusCode).toBe(200);
      expect(res.body.id).toBe(generatedStory.id);
      expect(res.body.story.act1Hook).toBeDefined();
    });

    it('should list user stories', async () => {
      const res = await request(app)
        .get('/api/stories')
        .set('Authorization', `Bearer ${authToken}`);

      expect(res.statusCode).toBe(200);
      expect(Array.isArray(res.body)).toBe(true);
      expect(res.body.length).toBeGreaterThan(0);
    });

    it('should enforce free tier limits', async () => {
      // Create multiple stories to hit limit
      for (let i = 0; i < 5; i++) {
        await request(app)
          .post('/api/stories/generate')
          .set('Authorization', `Bearer ${authToken}`)
          .send({
            clientProfileId: clientProfile.id,
          });
      }

      // Next story should fail
      const res = await request(app)
        .post('/api/stories/generate')
        .set('Authorization', `Bearer ${authToken}`)
        .send({
          clientProfileId: clientProfile.id,
        });

      expect(res.statusCode).toBe(403);
      expect(res.body.error).toContain('Free tier limit');
    });
  });

  describe('4. Practice Coaching', () => {
    it('should submit practice attempt with transcription', async () => {
      const res = await request(app)
        .post(`/api/stories/${generatedStory.id}/practice`)
        .set('Authorization', `Bearer ${authToken}`)
        .send({
          audioUrl: 's3://bucket/audio/practice.wav',
          transcription:
            'I understand your pain with long sales cycles. Let me tell you about a similar client...',
        });

      expect(res.statusCode).toBe(201);
      expect(res.body).toHaveProperty('attemptId');
      expect(res.body).toHaveProperty('score');
      expect(res.body.score).toBeGreaterThan(0);
      expect(res.body.score).toBeLessThanOrEqual(10);
    });

    it('should track delivery improvements across attempts', async () => {
      const attempt1 = await request(app)
        .post(`/api/stories/${generatedStory.id}/practice`)
        .set('Authorization', `Bearer ${authToken}`)
        .send({
          audioUrl: 's3://bucket/audio/practice1.wav',
          transcription: 'First attempt with basic delivery...',
        });

      const attempt2 = await request(app)
        .post(`/api/stories/${generatedStory.id}/practice`)
        .set('Authorization', `Bearer ${authToken}`)
        .send({
          audioUrl: 's3://bucket/audio/practice2.wav',
          transcription:
            'Second attempt with improved pacing and emotional delivery...',
        });

      expect(attempt1.statusCode).toBe(201);
      expect(attempt2.statusCode).toBe(201);
      // Scores should reflect practice improvement
      expect(attempt2.body.score).toBeGreaterThanOrEqual(attempt1.body.score);
    });

    it('should require transcription for practice submission', async () => {
      const res = await request(app)
        .post(`/api/stories/${generatedStory.id}/practice`)
        .set('Authorization', `Bearer ${authToken}`)
        .send({
          audioUrl: 's3://bucket/audio/practice.wav',
          // Missing transcription
        });

      expect(res.statusCode).toBe(400);
      expect(res.body.error).toContain('Transcription');
    });
  });

  describe('5. Analytics & Metrics', () => {
    it('should retrieve analytics summary', async () => {
      const res = await request(app)
        .get('/api/analytics/summary')
        .set('Authorization', `Bearer ${authToken}`);

      expect(res.statusCode).toBe(200);
      expect(res.body).toHaveProperty('totalStories');
      expect(res.body).toHaveProperty('avgDeliveryScore');
      expect(res.body).toHaveProperty('totalPracticeAttempts');
      expect(res.body).toHaveProperty('conversionRate');
    });

    it('should track story performance', async () => {
      const res = await request(app)
        .get('/api/analytics/stories')
        .set('Authorization', `Bearer ${authToken}`);

      expect(res.statusCode).toBe(200);
      expect(res.body).toHaveProperty('stories');
      expect(Array.isArray(res.body.stories)).toBe(true);
    });

    it('should track delivery trends', async () => {
      const res = await request(app)
        .get('/api/analytics/trends/delivery')
        .set('Authorization', `Bearer ${authToken}`);

      expect(res.statusCode).toBe(200);
      expect(res.body).toHaveProperty('trends');
    });

    it('should log meeting outcomes', async () => {
      const res = await request(app)
        .post('/api/analytics/meetings')
        .set('Authorization', `Bearer ${authToken}`)
        .send({
          storyId: generatedStory.id,
          clientName: 'John Smith',
          dealAdvanced: true,
        });

      expect(res.statusCode).toBe(201);
      expect(res.body).toHaveProperty('id');
      expect(res.body.dealAdvanced).toBe(true);
    });
  });

  describe('6. Error Handling', () => {
    it('should reject unauthenticated requests', async () => {
      const res = await request(app).get('/api/stories');

      expect(res.statusCode).toBe(401);
    });

    it('should reject invalid tokens', async () => {
      const res = await request(app)
        .get('/api/stories')
        .set('Authorization', 'Bearer invalid.token');

      expect(res.statusCode).toBe(401);
    });

    it('should return 404 for non-existent resources', async () => {
      const res = await request(app)
        .get('/api/stories/non-existent-id')
        .set('Authorization', `Bearer ${authToken}`);

      expect(res.statusCode).toBe(404);
    });

    it('should handle database errors gracefully', async () => {
      const res = await request(app)
        .get('/api/profiles/invalid-id')
        .set('Authorization', `Bearer ${authToken}`);

      expect(res.statusCode).toBe(404);
    });
  });

  describe('7. Performance', () => {
    it('story generation should complete under 5 seconds', async () => {
      const startTime = Date.now();

      const res = await request(app)
        .post('/api/stories/generate')
        .set('Authorization', `Bearer ${authToken}`)
        .send({
          clientProfileId: clientProfile.id,
        });

      const duration = Date.now() - startTime;

      expect(res.statusCode).toBe(201);
      expect(duration).toBeLessThan(5000);
    });

    it('analytics queries should complete under 500ms', async () => {
      const startTime = Date.now();

      const res = await request(app)
        .get('/api/analytics/summary')
        .set('Authorization', `Bearer ${authToken}`);

      const duration = Date.now() - startTime;

      expect(res.statusCode).toBe(200);
      expect(duration).toBeLessThan(500);
    });
  });
});
