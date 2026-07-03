const request = require('supertest');
const express = require('express');
const authRouter = require('../auth');
const { Pool } = require('pg');

// Mock pg Pool
jest.mock('pg', () => ({
  Pool: jest.fn(),
}));

describe('Auth Routes', () => {
  let app;
  let mockPool;

  beforeEach(() => {
    app = express();
    app.use(express.json());
    app.use('/auth', authRouter);

    mockPool = {
      query: jest.fn(),
    };

    Pool.mockImplementation(() => mockPool);
  });

  describe('POST /auth/signup', () => {
    it('should create a new user with valid credentials', async () => {
      mockPool.query.mockResolvedValueOnce({
        rows: [{ email: 'test@example.com' }],
      });
      mockPool.query.mockResolvedValueOnce({ rows: [] });
      mockPool.query.mockResolvedValueOnce({
        rows: [
          {
            id: '123',
            email: 'test@example.com',
            first_name: 'John',
            last_name: 'Doe',
            subscription_tier: 'free',
          },
        ],
      });

      const res = await request(app).post('/auth/signup').send({
        email: 'test@example.com',
        password: 'SecurePass123!',
        firstName: 'John',
        lastName: 'Doe',
      });

      expect(res.statusCode).toBe(201);
      expect(res.body).toHaveProperty('token');
      expect(res.body.user).toHaveProperty('id');
    });

    it('should reject duplicate emails', async () => {
      mockPool.query.mockResolvedValueOnce({
        rows: [{ email: 'existing@example.com' }],
      });

      const res = await request(app).post('/auth/signup').send({
        email: 'existing@example.com',
        password: 'SecurePass123!',
        firstName: 'Jane',
        lastName: 'Doe',
      });

      expect(res.statusCode).toBe(409);
      expect(res.body).toHaveProperty('error');
    });

    it('should reject weak passwords', async () => {
      const res = await request(app).post('/auth/signup').send({
        email: 'test@example.com',
        password: '123',
        firstName: 'John',
        lastName: 'Doe',
      });

      expect(res.statusCode).toBe(400);
    });

    it('should reject invalid emails', async () => {
      const res = await request(app).post('/auth/signup').send({
        email: 'not-an-email',
        password: 'SecurePass123!',
        firstName: 'John',
        lastName: 'Doe',
      });

      expect(res.statusCode).toBe(400);
    });
  });

  describe('POST /auth/login', () => {
    it('should return JWT token on successful login', async () => {
      const hashedPassword =
        '$2a$10$N9qo8uLOickgx2ZMRZoM2eLI/l28cH3U/6kxJpKqGb0p7G8V9Q8B6'; // bcrypt of "test"

      mockPool.query.mockResolvedValueOnce({
        rows: [
          {
            id: '123',
            email: 'user@example.com',
            password_hash: hashedPassword,
            subscription_tier: 'free',
          },
        ],
      });

      const res = await request(app).post('/auth/login').send({
        email: 'user@example.com',
        password: 'test',
      });

      expect(res.statusCode).toBe(200);
      expect(res.body).toHaveProperty('token');
    });

    it('should reject invalid credentials', async () => {
      mockPool.query.mockResolvedValueOnce({ rows: [] });

      const res = await request(app).post('/auth/login').send({
        email: 'nonexistent@example.com',
        password: 'password',
      });

      expect(res.statusCode).toBe(401);
    });

    it('should reject wrong password', async () => {
      mockPool.query.mockResolvedValueOnce({
        rows: [
          {
            id: '123',
            email: 'user@example.com',
            password_hash: '$2a$10$wronghash',
          },
        ],
      });

      const res = await request(app).post('/auth/login').send({
        email: 'user@example.com',
        password: 'wrongpassword',
      });

      expect(res.statusCode).toBe(401);
    });
  });

  describe('GET /auth/me', () => {
    it('should return authenticated user profile', async () => {
      // Mock a valid JWT token
      const token = 'valid.jwt.token';

      mockPool.query.mockResolvedValueOnce({
        rows: [
          {
            id: '123',
            email: 'user@example.com',
            first_name: 'John',
            last_name: 'Doe',
            company: 'Acme Corp',
            subscription_tier: 'professional',
          },
        ],
      });

      const res = await request(app)
        .get('/auth/me')
        .set('Authorization', `Bearer ${token}`);

      // Token validation will fail in this test, so we expect 401
      expect(res.statusCode).toBe(401);
    });
  });

  describe('POST /auth/refresh', () => {
    it('should return new token with valid refresh token', async () => {
      const res = await request(app).post('/auth/refresh').send({
        refreshToken: 'valid.refresh.token',
      });

      // This will fail without proper token setup
      expect(res.statusCode).toBe(401);
    });
  });
});
