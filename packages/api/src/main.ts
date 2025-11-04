import { Hono } from 'hono';
import { logger as pinoLogger } from 'hono/logger';
import { cors } from 'hono/cors';
import { config } from './config';
import { logger } from './services/logger';

const app = new Hono();

// Middleware
app.use('*', pinoLogger());
app.use('*', cors());

// Health check
app.get('/health', (c) => {
  return c.json({
    status: 'ok',
    timestamp: new Date().toISOString(),
    environment: config.NODE_ENV,
  });
});

// API routes
app.get('/api/v1', (c) => {
  return c.json({
    message: 'SuitrumpDEX API v1',
    version: '1.0.0',
    docs: '/api/v1/docs',
  });
});

// Start server
const port = config.API_PORT;

logger.info(`🚀 Starting SuitrumpDEX API...`);
logger.info(`Environment: ${config.NODE_ENV}`);
logger.info(`Port: ${port}`);

export default {
  port,
  fetch: app.fetch,
};

logger.info(`✅ API server started on http://localhost:${port}`);
