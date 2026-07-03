const express = require('express');
const cors = require('cors');
const morgan = require('morgan');
const helmet = require('helmet');
const rateLimit = require('express-rate-limit');
const { Pool } = require('pg');
const redis = require('redis');
require('dotenv').config();

const app = express();
const port = process.env.PORT || 3000;

// ============================================================================
// MIDDLEWARE SETUP
// ============================================================================

// Security headers
app.use(helmet());

// CORS
app.use(cors({
  origin: process.env.CLIENT_URL || 'http://localhost:3000',
  credentials: true,
}));

// Logging
app.use(morgan('combined'));

// Body parsing
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ limit: '10mb', extended: true }));

// Rate limiting
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100, // limit each IP to 100 requests per windowMs
  message: 'Too many requests from this IP, please try again later.',
});
app.use('/api/', limiter);

// ============================================================================
// DATABASE & CACHE SETUP
// ============================================================================

// PostgreSQL Connection Pool
const pgPool = new Pool({
  connectionString: process.env.DATABASE_URL,
  max: 20,
  idleTimeoutMillis: 30000,
  connectionTimeoutMillis: 2000,
});

pgPool.on('error', (err) => {
  console.error('Unexpected error on idle client', err);
});

// Redis Client
const redisClient = redis.createClient({
  url: process.env.REDIS_URL,
  socket: {
    reconnectStrategy: (retries) => Math.min(retries * 50, 500),
  },
});

redisClient.on('error', (err) => {
  console.error('Redis Client Error', err);
});

redisClient.connect().catch((err) => {
  console.error('Failed to connect to Redis:', err);
});

// ============================================================================
// HEALTH CHECK ENDPOINT
// ============================================================================

app.get('/health', async (req, res) => {
  try {
    // Check database
    const dbCheck = await pgPool.query('SELECT 1');

    // Check Redis
    const cacheCheck = await redisClient.ping();

    res.json({
      status: 'healthy',
      timestamp: new Date().toISOString(),
      database: dbCheck ? 'connected' : 'error',
      cache: cacheCheck === 'PONG' ? 'connected' : 'error',
      uptime: process.uptime(),
    });
  } catch (err) {
    console.error('Health check failed:', err);
    res.status(503).json({
      status: 'unhealthy',
      error: err.message,
    });
  }
});

// ============================================================================
// API ROUTES
// ============================================================================

// Import route handlers
const authRoutes = require('./routes/auth');
const profileRoutes = require('./routes/profiles');
const storyRoutes = require('./routes/stories');
const analyticsRoutes = require('./routes/analytics');

// Register routes
app.use('/api/auth', authRoutes);
app.use('/api/profiles', profileRoutes);
app.use('/api/stories', storyRoutes);
app.use('/api/analytics', analyticsRoutes);

// ============================================================================
// ERROR HANDLING
// ============================================================================

// 404 handler
app.use((req, res) => {
  res.status(404).json({
    error: 'Route not found',
    path: req.path,
    method: req.method,
  });
});

// Global error handler
app.use((err, req, res, next) => {
  console.error('Error:', err);

  const status = err.status || 500;
  const message = err.message || 'Internal Server Error';

  res.status(status).json({
    error: {
      status,
      message,
      timestamp: new Date().toISOString(),
    },
  });
});

// ============================================================================
// SERVER STARTUP
// ============================================================================

const server = app.listen(port, () => {
  console.log(`
╔════════════════════════════════════════════════════════════╗
║           StoryForce.AI Backend API Server                ║
║           Listening on http://localhost:${port}            ║
║                                                            ║
║  Environment: ${process.env.NODE_ENV || 'development'}                          ║
║  Database: ${process.env.DATABASE_URL ? 'connected' : 'not configured'}                  ║
║  Cache: ${process.env.REDIS_URL ? 'connected' : 'not configured'}                        ║
╚════════════════════════════════════════════════════════════╝
  `);
});

// Graceful shutdown
process.on('SIGTERM', () => {
  console.log('SIGTERM received, shutting down gracefully...');
  server.close(() => {
    pgPool.end();
    redisClient.quit();
    console.log('Server closed');
    process.exit(0);
  });
});

// Export for testing
module.exports = { app, pgPool, redisClient };
