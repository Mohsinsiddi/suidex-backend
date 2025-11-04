import { logger } from './utils/logger';
import { config } from './config';
import { testConnection, closeConnection } from './db/client';
import { CheckpointManager } from './services/checkpoint';
import { EventProcessor } from './services/event-processor';
import { SuiEventSubscriber } from './services/sui-client';
import { emissionConfig } from './services/emission-config';

async function main() {
  logger.info('🚀 Starting SuitrumpDEX Indexer...');
  logger.info(`Environment: ${config.NODE_ENV}`);
  logger.info(`Database: ${config.DATABASE_URL.split('@')[1]}`);
  logger.info(`Sui RPC: ${config.SUI_RPC_URL}`);
  
  // Test database connection
  const dbConnected = await testConnection();
  if (!dbConnected) {
    throw new Error('Database connection failed');
  }
  
  // Initialize emission config from contract (REQUIRED for epoch calculations)
  logger.info('📅 Initializing emission config...');
  await emissionConfig.initialize();
  logger.info(`Emission start: ${new Date(emissionConfig.getEmissionStartTime() * 1000).toISOString()}`);
  logger.info(`Current week: ${emissionConfig.getCurrentWeek()}`);
  
  // Load checkpoints
  const checkpointManager = new CheckpointManager();
  await checkpointManager.loadCheckpoints();
  
  logger.info('Loaded checkpoints:', checkpointManager.getAllCheckpoints());
  
  // Start event processing
  const eventProcessor = new EventProcessor();
  const suiSubscriber = new SuiEventSubscriber(checkpointManager, eventProcessor);
  await suiSubscriber.start();
  
  logger.info('✅ Indexer started successfully');
  logger.info('📡 Listening for blockchain events...');
  
  const shutdown = async () => {
    logger.info('🛑 Shutting down indexer...');
    await suiSubscriber.stop();
    await closeConnection();
    logger.info('👋 Indexer stopped');
    process.exit(0);
  };
  
  process.on('SIGTERM', shutdown);
  process.on('SIGINT', shutdown);
  
  setInterval(() => {
    const checkpoints = checkpointManager.getAllCheckpoints();
    const currentWeek = emissionConfig.getCurrentWeek();
    logger.debug({ checkpoints, currentWeek }, 'Indexer heartbeat');
  }, 30000);
}

main().catch((error) => {
  logger.error(error, '❌ Failed to start indexer');
  process.exit(1);
});