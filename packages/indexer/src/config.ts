import { z } from 'zod';

const configSchema = z.object({
  NODE_ENV: z.enum(['development', 'production', 'test']).default('development'),
  DATABASE_URL: z.string().url(),
  DATABASE_POOL_SIZE: z.string().transform(Number).default('20'),
  REDIS_URL: z.string().url(),
  SUI_RPC_URL: z.string().url(),
  SUI_GRAPHQL_URL: z.string().url(),
  PAIR_PACKAGE_ID: z.string(),
  FARM_PACKAGE_ID: z.string(),
  LOCKER_PACKAGE_ID: z.string(),
  EMISSION_CONTROLLER_ADDRESS: z.string(),
  LOG_LEVEL: z.enum(['debug', 'info', 'warn', 'error']).default('info'),
});

export const config = configSchema.parse(process.env);