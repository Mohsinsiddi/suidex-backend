import postgres from 'postgres';
import { config } from '../config';
import { logger } from '../utils/logger';

export const sql = postgres(config.DATABASE_URL, {
  max: config.DATABASE_POOL_SIZE,
  idle_timeout: 20,
  connect_timeout: 10,
  prepare: true,
  onnotice: () => {},
  debug: config.NODE_ENV === 'development',
});

export async function testConnection(): Promise<boolean> {
  try {
    await sql`SELECT 1 as test`;
    logger.info('✅ Database connection successful');
    return true;
  } catch (error) {
    logger.error(error, '❌ Database connection failed');
    return false;
  }
}

export async function executeWithRetry<T>(
  queryFn: () => Promise<T>,
  maxRetries = 3,
  delayMs = 1000
): Promise<T> {
  let lastError: Error | null = null;
  
  for (let attempt = 1; attempt <= maxRetries; attempt++) {
    try {
      return await queryFn();
    } catch (error) {
      lastError = error as Error;
      logger.warn({ attempt, maxRetries, error: lastError.message }, 'Query failed, retrying...');
      
      if (attempt < maxRetries) {
        await new Promise(resolve => setTimeout(resolve, delayMs * attempt));
      }
    }
  }
  
  throw lastError;
}

export async function closeConnection(): Promise<void> {
  await sql.end({ timeout: 5 });
  logger.info('Database connection closed');
}

process.on('SIGTERM', closeConnection);
process.on('SIGINT', closeConnection);
