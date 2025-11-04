import { z } from 'zod';

const configSchema = z.object({
  NODE_ENV: z.enum(['development', 'production', 'test']).default('development'),
  API_PORT: z.string().transform(Number).default('3000'),
  API_HOST: z.string().default('0.0.0.0'),
  DATABASE_URL: z.string().url(),
  REDIS_URL: z.string().url(),
  JWT_SECRET: z.string().min(32),
  RATE_LIMIT_FREE: z.string().transform(Number).default('100'),
  RATE_LIMIT_BASIC: z.string().transform(Number).default('1000'),
  RATE_LIMIT_PRO: z.string().transform(Number).default('10000'),
  RATE_LIMIT_ENTERPRISE: z.string().transform(Number).default('100000'),
});

export const config = configSchema.parse(process.env);
