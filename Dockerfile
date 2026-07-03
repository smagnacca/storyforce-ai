# Multi-stage Docker build for StoryForce.AI backend
# Stage 1: Build
FROM node:18-alpine AS builder

WORKDIR /app

# Copy package files
COPY code/backend/package*.json ./

# Install dependencies (including dev dependencies for build tools)
RUN npm ci

# Copy application code
COPY code/backend/src ./src
COPY code/backend/migrations ./migrations

# Run linter
RUN npm run lint || true

# Stage 2: Runtime
FROM node:18-alpine

WORKDIR /app

# Install dumb-init for signal handling
RUN apk add --no-cache dumb-init

# Create non-root user
RUN addgroup -g 1000 storyforce && adduser -D -u 1000 -G storyforce storyforce

# Copy package files
COPY code/backend/package*.json ./

# Install production dependencies only
RUN npm ci --only=production

# Copy application code from builder
COPY --from=builder /app/src ./src
COPY --from=builder /app/migrations ./migrations

# Copy environment template
COPY code/backend/.env.example .env.example

# Change ownership
RUN chown -R storyforce:storyforce /app

# Switch to non-root user
USER storyforce

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD node -e "require('http').get('http://localhost:3000/health', (r) => { if (r.statusCode !== 200) throw new Error(r.statusCode) })"

# Expose port
EXPOSE 3000

# Use dumb-init to handle signals properly
ENTRYPOINT ["/usr/sbin/dumb-init", "--"]

# Start application
CMD ["node", "src/server.js"]
