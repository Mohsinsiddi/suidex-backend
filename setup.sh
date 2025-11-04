#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}🚀 Setting up SuitrumpDEX Backend...${NC}\n"

# Check if bun is installed
if ! command -v bun &> /dev/null; then
    echo -e "${YELLOW}📦 Installing Bun...${NC}"
    curl -fsSL https://bun.sh/install | bash
    export PATH="$HOME/.bun/bin:$PATH"
fi

# Create root directory
mkdir -p suitrump-backend
cd suitrump-backend

echo -e "${GREEN}📁 Creating project structure...${NC}"

# Create all directories
mkdir -p packages/indexer/src/{db,parsers,services,utils}
mkdir -p packages/api/src/{routes,middleware,services,types}
mkdir -p packages/shared/src/{types,utils}
mkdir -p database
mkdir -p docker
mkdir -p logs
mkdir -p scripts

# Create root package.json
cat > package.json << 'EOF'
{
  "name": "suitrump-backend",
  "version": "1.0.0",
  "private": true,
  "workspaces": [
    "packages/*"
  ],
  "scripts": {
    "dev:indexer": "bun --watch packages/indexer/src/main.ts",
    "dev:api": "bun --watch packages/api/src/main.ts",
    "dev": "concurrently \"bun run dev:indexer\" \"bun run dev:api\"",
    "build": "bun run build:indexer && bun run build:api",
    "build:indexer": "cd packages/indexer && bun build src/main.ts --outdir dist --target bun",
    "build:api": "cd packages/api && bun build src/main.ts --outdir dist --target bun",
    "db:migrate": "bun run scripts/migrate.ts",
    "db:seed": "bun run scripts/seed.ts",
    "test": "bun test",
    "lint": "eslint . --ext .ts",
    "format": "prettier --write '**/*.{ts,json,md}'",
    "clean": "rm -rf packages/*/dist node_modules packages/*/node_modules"
  },
  "devDependencies": {
    "@types/bun": "latest",
    "concurrently": "^8.2.2",
    "eslint": "^8.52.0",
    "@typescript-eslint/eslint-plugin": "^6.9.1",
    "@typescript-eslint/parser": "^6.9.1",
    "prettier": "^3.0.3",
    "typescript": "^5.2.2"
  }
}
EOF

# Create root tsconfig.json
cat > tsconfig.json << 'EOF'
{
  "compilerOptions": {
    "lib": ["ESNext"],
    "target": "ESNext",
    "module": "ESNext",
    "moduleDetection": "force",
    "jsx": "react-jsx",
    "allowJs": true,
    "moduleResolution": "bundler",
    "allowImportingTsExtensions": true,
    "verbatimModuleSyntax": true,
    "noEmit": true,
    "strict": true,
    "skipLibCheck": true,
    "noFallthroughCasesInSwitch": true,
    "noUnusedLocals": false,
    "noUnusedParameters": false,
    "noPropertyAccessFromIndexSignature": false,
    "esModuleInterop": true,
    "resolveJsonModule": true,
    "isolatedModules": true,
    "paths": {
      "@shared/*": ["./packages/shared/src/*"]
    }
  }
}
EOF

# Create .env.example
cat > .env.example << 'EOF'
# Database
DATABASE_URL=postgres://postgres:postgres@localhost:5432/suitrump_dex
DATABASE_POOL_SIZE=20

# Redis
REDIS_URL=redis://localhost:6379
REDIS_PASSWORD=

# Sui Network
SUI_RPC_URL=https://fullnode.mainnet.sui.io:443
SUI_GRAPHQL_URL=https://sui-mainnet.mystenlabs.com/graphql

# Contract Addresses (UPDATE THESE!)
PAIR_PACKAGE_ID=0x...
FARM_PACKAGE_ID=0x...
LOCKER_PACKAGE_ID=0x...

# Price Oracle
PYTH_NETWORK_URL=https://hermes.pyth.network
PYTH_PRICE_SERVICE_URL=https://xc-mainnet.pyth.network

# API Configuration
API_PORT=3000
API_HOST=0.0.0.0
JWT_SECRET=your-secret-key-change-this-in-production

# Rate Limiting (requests per minute)
RATE_LIMIT_FREE=100
RATE_LIMIT_BASIC=1000
RATE_LIMIT_PRO=10000
RATE_LIMIT_ENTERPRISE=100000

# Monitoring
SENTRY_DSN=
GRAFANA_URL=http://localhost:3001

# Environment
NODE_ENV=development
LOG_LEVEL=debug
EOF

# Copy to .env
cp .env.example .env

# Create .gitignore
cat > .gitignore << 'EOF'
# Dependencies
node_modules/
.pnp
.pnp.js

# Testing
coverage/
*.lcov

# Production
dist/
build/

# Misc
.DS_Store
*.log
logs/
*.pid
*.seed
*.pid.lock

# Environment
.env
.env.local
.env.production

# IDE
.idea/
.vscode/
*.swp
*.swo
*~

# Bun
.bun/
bun.lockb

# Database
*.db
*.sqlite
EOF

# Create README.md
cat > README.md << 'EOF'
# 🚀 SuitrumpDEX Backend

High-performance blockchain indexer and API service for SuitrumpDEX built with Bun + TypeScript.

## 🏗️ Architecture

- **Indexer Service**: Real-time event indexing from Sui blockchain
- **API Service**: REST/GraphQL API with Redis caching
- **TimescaleDB**: Time-series optimized PostgreSQL
- **Redis**: High-speed caching and rate limiting

## 📦 Installation
```bash
# Install dependencies
bun install

# Setup database
docker-compose up -d
bun run db:migrate

# Start services
bun run dev
```

## 🚀 Development
```bash
# Run indexer
bun run dev:indexer

# Run API
bun run dev:api

# Run both
bun run dev
```

## 📊 Monitoring

- API: http://localhost:3000
- Grafana: http://localhost:3001
- Prometheus: http://localhost:9090

## 🧪 Testing
```bash
bun test
```

## 📝 License

MIT
EOF

# ============================================================================
# SHARED PACKAGE
# ============================================================================

echo -e "${GREEN}📦 Setting up shared package...${NC}"

cat > packages/shared/package.json << 'EOF'
{
  "name": "@suitrump/shared",
  "version": "1.0.0",
  "main": "src/index.ts",
  "types": "src/index.ts",
  "dependencies": {
    "zod": "^3.22.4"
  }
}
EOF

cat > packages/shared/tsconfig.json << 'EOF'
{
  "extends": "../../tsconfig.json",
  "compilerOptions": {
    "outDir": "./dist",
    "rootDir": "./src"
  },
  "include": ["src/**/*"]
}
EOF

# Create shared types
cat > packages/shared/src/types/events.ts << 'EOF'
// Event type definitions will go here
export interface SwapEvent {
  sender: string;
  amount0_in: string;
  amount1_in: string;
  amount0_out: string;
  amount1_out: string;
}

export interface LPMintEvent {
  sender: string;
  lp_coin_id: string;
  token0_type: string;
  token1_type: string;
  amount0: string;
  amount1: string;
  liquidity: string;
  total_supply: string;
}

// More event types...
export interface ParsedSuiEvent<T> {
  id: {
    txDigest: string;
    eventSeq: string;
  };
  packageId: string;
  transactionModule: string;
  type: string;
  parsedJson: T;
  timestampMs: string;
}
EOF

cat > packages/shared/src/types/database.ts << 'EOF'
// Database type definitions
export type PoolType = 'lp' | 'single';
export type LockPeriod = 'week' | 'three_month' | 'year' | 'three_year';
export type TxStatus = 'success' | 'failed' | 'pending';
export type PositionStatus = 'active' | 'closed';
EOF

cat > packages/shared/src/constants.ts << 'EOF'
// Constants will go here
export const CONTRACTS = {
  PAIR_PACKAGE_ID: process.env.PAIR_PACKAGE_ID || '',
  FARM_PACKAGE_ID: process.env.FARM_PACKAGE_ID || '',
  LOCKER_PACKAGE_ID: process.env.LOCKER_PACKAGE_ID || '',
} as const;

export const DECIMALS = {
  SUI: 9,
  VICTORY: 6,
  DEFAULT: 6,
} as const;
EOF

cat > packages/shared/src/index.ts << 'EOF'
export * from './types/events';
export * from './types/database';
export * from './constants';
EOF

# ============================================================================
# INDEXER PACKAGE
# ============================================================================

echo -e "${GREEN}📦 Setting up indexer package...${NC}"

cat > packages/indexer/package.json << 'EOF'
{
  "name": "@suitrump/indexer",
  "version": "1.0.0",
  "main": "src/main.ts",
  "scripts": {
    "dev": "bun --watch src/main.ts",
    "start": "bun src/main.ts",
    "build": "bun build src/main.ts --outdir dist --target bun"
  },
  "dependencies": {
    "@mysten/sui.js": "^0.54.1",
    "postgres": "^3.4.3",
    "ioredis": "^5.3.2",
    "pino": "^8.16.2",
    "pino-pretty": "^10.2.3",
    "dotenv": "^16.3.1",
    "zod": "^3.22.4"
  },
  "devDependencies": {
    "@types/node": "^20.9.0",
    "bun-types": "latest"
  }
}
EOF

cat > packages/indexer/tsconfig.json << 'EOF'
{
  "extends": "../../tsconfig.json",
  "compilerOptions": {
    "outDir": "./dist",
    "rootDir": "./src"
  },
  "include": ["src/**/*"]
}
EOF

# Create indexer main file
cat > packages/indexer/src/main.ts << 'EOF'
import { logger } from './utils/logger';
import { config } from './config';

async function main() {
  logger.info('🚀 Starting SuitrumpDEX Indexer...');
  logger.info(`Environment: ${config.NODE_ENV}`);
  logger.info(`Database: ${config.DATABASE_URL.split('@')[1]}`);
  
  // TODO: Initialize services
  
  logger.info('✅ Indexer started successfully');
}

main().catch((error) => {
  logger.error(error, '❌ Failed to start indexer');
  process.exit(1);
});
EOF

cat > packages/indexer/src/config.ts << 'EOF'
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
  LOG_LEVEL: z.enum(['debug', 'info', 'warn', 'error']).default('info'),
});

export const config = configSchema.parse(process.env);
EOF

cat > packages/indexer/src/utils/logger.ts << 'EOF'
import pino from 'pino';
import { config } from '../config';

export const logger = pino({
  level: config.LOG_LEVEL,
  transport: config.NODE_ENV === 'development' ? {
    target: 'pino-pretty',
    options: {
      colorize: true,
      translateTime: 'HH:MM:ss',
      ignore: 'pid,hostname',
    },
  } : undefined,
});
EOF

# Create empty files for indexer
touch packages/indexer/src/db/client.ts
touch packages/indexer/src/db/queries.ts
touch packages/indexer/src/parsers/pair.ts
touch packages/indexer/src/parsers/farm.ts
touch packages/indexer/src/parsers/locker.ts
touch packages/indexer/src/services/checkpoint.ts
touch packages/indexer/src/services/price-oracle.ts
touch packages/indexer/src/services/sui-client.ts
touch packages/indexer/src/utils/math.ts

# ============================================================================
# API PACKAGE
# ============================================================================

echo -e "${GREEN}📦 Setting up API package...${NC}"

cat > packages/api/package.json << 'EOF'
{
  "name": "@suitrump/api",
  "version": "1.0.0",
  "main": "src/main.ts",
  "scripts": {
    "dev": "bun --watch src/main.ts",
    "start": "bun src/main.ts",
    "build": "bun build src/main.ts --outdir dist --target bun"
  },
  "dependencies": {
    "hono": "^3.11.2",
    "postgres": "^3.4.3",
    "ioredis": "^5.3.2",
    "jose": "^5.1.3",
    "pino": "^8.16.2",
    "pino-pretty": "^10.2.3",
    "dotenv": "^16.3.1",
    "zod": "^3.22.4"
  },
  "devDependencies": {
    "@types/node": "^20.9.0",
    "bun-types": "latest"
  }
}
EOF

cat > packages/api/tsconfig.json << 'EOF'
{
  "extends": "../../tsconfig.json",
  "compilerOptions": {
    "outDir": "./dist",
    "rootDir": "./src"
  },
  "include": ["src/**/*"]
}
EOF

# Create API main file
cat > packages/api/src/main.ts << 'EOF'
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
EOF

cat > packages/api/src/config.ts << 'EOF'
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
EOF

cat > packages/api/src/services/logger.ts << 'EOF'
import pino from 'pino';

const isDev = process.env.NODE_ENV === 'development';

export const logger = pino({
  level: process.env.LOG_LEVEL || 'info',
  transport: isDev ? {
    target: 'pino-pretty',
    options: {
      colorize: true,
      translateTime: 'HH:MM:ss',
      ignore: 'pid,hostname',
    },
  } : undefined,
});
EOF

# Create empty files for API
touch packages/api/src/routes/pairs.ts
touch packages/api/src/routes/tokens.ts
touch packages/api/src/routes/users.ts
touch packages/api/src/routes/farms.ts
touch packages/api/src/routes/locker.ts
touch packages/api/src/routes/analytics.ts
touch packages/api/src/middleware/auth.ts
touch packages/api/src/middleware/rate-limit.ts
touch packages/api/src/middleware/cors.ts
touch packages/api/src/services/cache.ts
touch packages/api/src/services/db.ts
touch packages/api/src/types/api.ts

# ============================================================================
# DOCKER SETUP
# ============================================================================

echo -e "${GREEN}🐳 Creating Docker configuration...${NC}"

cat > docker/Dockerfile.indexer << 'EOF'
FROM oven/bun:1 as base
WORKDIR /app

# Install dependencies
COPY package.json bun.lockb ./
COPY packages/indexer/package.json ./packages/indexer/
COPY packages/shared/package.json ./packages/shared/
RUN bun install --frozen-lockfile

# Copy source
COPY packages/indexer ./packages/indexer
COPY packages/shared ./packages/shared

# Build
RUN cd packages/indexer && bun build src/main.ts --outdir dist --target bun

# Production
FROM oven/bun:1-slim
WORKDIR /app
COPY --from=base /app/packages/indexer/dist ./dist
COPY --from=base /app/node_modules ./node_modules

CMD ["bun", "dist/main.js"]
EOF

cat > docker/Dockerfile.api << 'EOF'
FROM oven/bun:1 as base
WORKDIR /app

# Install dependencies
COPY package.json bun.lockb ./
COPY packages/api/package.json ./packages/api/
COPY packages/shared/package.json ./packages/shared/
RUN bun install --frozen-lockfile

# Copy source
COPY packages/api ./packages/api
COPY packages/shared ./packages/shared

# Build
RUN cd packages/api && bun build src/main.ts --outdir dist --target bun

# Production
FROM oven/bun:1-slim
WORKDIR /app
COPY --from=base /app/packages/api/dist ./dist
COPY --from=base /app/node_modules ./node_modules

EXPOSE 3000
CMD ["bun", "dist/main.js"]
EOF

cat > docker-compose.yml << 'EOF'
version: '3.8'

services:
  timescaledb:
    image: timescale/timescaledb-ha:pg16
    container_name: suitrump-db
    environment:
      POSTGRES_DB: suitrump_dex
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres
      POSTGRES_INITDB_ARGS: "-E UTF8"
    volumes:
      - timescale-data:/var/lib/postgresql/data
      - ./database:/docker-entrypoint-initdb.d:ro
    ports:
      - "5432:5432"
    command: 
      - postgres
      - -c
      - shared_preload_libraries=timescaledb
      - -c
      - max_connections=200
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 10s
      timeout: 5s
      retries: 5

  redis:
    image: redis:7-alpine
    container_name: suitrump-redis
    command: redis-server --appendonly yes --maxmemory 2gb --maxmemory-policy allkeys-lru
    volumes:
      - redis-data:/data
    ports:
      - "6379:6379"
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 10s
      timeout: 5s
      retries: 5

  pgbouncer:
    image: edoburu/pgbouncer:latest
    container_name: suitrump-pgbouncer
    environment:
      DATABASE_URL: postgres://postgres:postgres@timescaledb/suitrump_dex
      POOL_MODE: transaction
      MAX_CLIENT_CONN: 1000
      DEFAULT_POOL_SIZE: 25
      MIN_POOL_SIZE: 10
      RESERVE_POOL_SIZE: 5
    ports:
      - "6432:6432"
    depends_on:
      timescaledb:
        condition: service_healthy

  indexer:
    build:
      context: .
      dockerfile: docker/Dockerfile.indexer
    container_name: suitrump-indexer
    env_file:
      - .env
    environment:
      DATABASE_URL: postgres://postgres:postgres@pgbouncer:6432/suitrump_dex
      REDIS_URL: redis://redis:6379
    depends_on:
      - timescaledb
      - redis
      - pgbouncer
    restart: unless-stopped
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"

  api:
    build:
      context: .
      dockerfile: docker/Dockerfile.api
    container_name: suitrump-api
    env_file:
      - .env
    environment:
      DATABASE_URL: postgres://postgres:postgres@pgbouncer:6432/suitrump_dex
      REDIS_URL: redis://redis:6379
      API_PORT: 3000
    ports:
      - "3000:3000"
    depends_on:
      - timescaledb
      - redis
      - pgbouncer
    restart: unless-stopped
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"

  prometheus:
    image: prom/prometheus:latest
    container_name: suitrump-prometheus
    volumes:
      - ./docker/prometheus.yml:/etc/prometheus/prometheus.yml:ro
      - prometheus-data:/prometheus
    ports:
      - "9090:9090"
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.path=/prometheus'
      - '--storage.tsdb.retention.time=30d'

  grafana:
    image: grafana/grafana:latest
    container_name: suitrump-grafana
    environment:
      GF_SECURITY_ADMIN_PASSWORD: admin
      GF_USERS_ALLOW_SIGN_UP: 'false'
    volumes:
      - grafana-data:/var/lib/grafana
    ports:
      - "3001:3000"
    depends_on:
      - prometheus

volumes:
  timescale-data:
  redis-data:
  prometheus-data:
  grafana-data:
EOF

cat > docker/prometheus.yml << 'EOF'
global:
  scrape_interval: 15s
  evaluation_interval: 15s

scrape_configs:
  - job_name: 'api'
    static_configs:
      - targets: ['api:3000']
  
  - job_name: 'indexer'
    static_configs:
      - targets: ['indexer:9091']
EOF

# ============================================================================
# DATABASE MIGRATIONS
# ============================================================================

echo -e "${GREEN}🗄️  Creating database migrations...${NC}"

# Create migration script
cat > scripts/migrate.ts << 'EOF'
#!/usr/bin/env bun

import { readdir } from 'fs/promises';
import { join } from 'path';
import postgres from 'postgres';

const sql = postgres(process.env.DATABASE_URL!);

async function migrate() {
  console.log('🚀 Running database migrations...');
  
  const migrationsDir = join(import.meta.dir, '../database');
  const files = await readdir(migrationsDir);
  const sqlFiles = files.filter(f => f.endsWith('.sql')).sort();
  
  for (const file of sqlFiles) {
    console.log(`  📄 Executing ${file}...`);
    const content = await Bun.file(join(migrationsDir, file)).text();
    await sql.unsafe(content);
  }
  
  console.log('✅ Migrations completed!');
  await sql.end();
}

migrate().catch(console.error);
EOF

chmod +x scripts/migrate.ts

# Create placeholder migration files
touch database/001_extensions.sql
touch database/002_types.sql
touch database/003_core_tables.sql
touch database/004_dex_events.sql
touch database/005_farm_events.sql
touch database/006_locker_events.sql
touch database/007_positions.sql
touch database/008_indexes.sql
touch database/009_compression.sql
touch database/010_functions.sql

# ============================================================================
# ESLint & Prettier
# ============================================================================

cat > .eslintrc.json << 'EOF'
{
  "parser": "@typescript-eslint/parser",
  "extends": [
    "eslint:recommended",
    "plugin:@typescript-eslint/recommended"
  ],
  "plugins": ["@typescript-eslint"],
  "rules": {
    "@typescript-eslint/no-unused-vars": ["warn", { "argsIgnorePattern": "^_" }],
    "@typescript-eslint/no-explicit-any": "warn"
  }
}
EOF

cat > .prettierrc << 'EOF'
{
  "semi": true,
  "trailingComma": "es5",
  "singleQuote": true,
  "printWidth": 100,
  "tabWidth": 2
}
EOF

# ============================================================================
# INSTALL DEPENDENCIES
# ============================================================================

echo -e "${GREEN}📦 Installing dependencies...${NC}"

# Install root dependencies
bun install

# Install package dependencies
cd packages/shared && bun install && cd ../..
cd packages/indexer && bun install && cd ../..
cd packages/api && bun install && cd ../..

echo -e "${GREEN}✅ Setup complete!${NC}\n"

echo -e "${YELLOW}📋 Next steps:${NC}"
echo -e "1. Update .env file with your contract addresses"
echo -e "2. Start Docker services: ${GREEN}docker-compose up -d${NC}"
echo -e "3. Run migrations: ${GREEN}bun run db:migrate${NC}"
echo -e "4. Start development: ${GREEN}bun run dev${NC}\n"

echo -e "${GREEN}🎉 Happy coding!${NC}"