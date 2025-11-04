import { logger } from './utils/logger';
import { config } from './config';

async function main() {
  logger.info('🚀 Starting SuitrumpDEX Indexer...');
  logger.info(`Environment: ${config.NODE_ENV}`);
  logger.info(`Database: ${config.DATABASE_URL.split('@')[1]}`);
  
  // TODO: Initialize services
  
  logger.info('✅ Indexer started successfully');
  
  // Keep process alive with interval
  setInterval(() => {
    logger.debug('Indexer heartbeat');
  }, 60000); // Log every minute
}

main().catch((error) => {
  logger.error(error, '❌ Failed to start indexer');
  process.exit(1);
});

// Prevent process exit
process.on('SIGTERM', () => {
  logger.info('Received SIGTERM, shutting down gracefully');
  process.exit(0);
});