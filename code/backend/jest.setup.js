/**
 * Jest Setup File
 * Mocks database and cache connections for testing
 */

// Mock PostgreSQL Pool
jest.mock('pg', () => {
  const mockPool = {
    query: jest.fn(async (sql, params) => {
      // Mock responses for common queries
      if (sql.includes('SELECT id FROM users WHERE email')) {
        return { rows: [] }; // User doesn't exist
      }
      if (sql.includes('INSERT INTO users')) {
        return {
          rows: [{
            id: 'user-001',
            email: params[0],
            first_name: params[2],
            last_name: params[3],
            company: params[4],
            subscription_tier: 'free'
          }]
        };
      }
      if (sql.includes('SELECT') && sql.includes('FROM users')) {
        return {
          rows: [{
            id: 'user-001',
            email: 'test@example.com',
            first_name: 'Test',
            last_name: 'User',
            company: 'Test Corp'
          }]
        };
      }
      return { rows: [] };
    }),
    end: jest.fn(async () => {}),
    on: jest.fn(),
  };

  return {
    Pool: jest.fn(() => mockPool)
  };
});

// Mock Redis Client
jest.mock('redis', () => ({
  createClient: jest.fn(() => ({
    get: jest.fn(async () => null),
    set: jest.fn(async () => 'OK'),
    del: jest.fn(async () => 1),
    connect: jest.fn(async () => {}),
    disconnect: jest.fn(async () => {}),
    on: jest.fn(),
  }))
}));

// Suppress console errors during tests
global.console.error = jest.fn();
