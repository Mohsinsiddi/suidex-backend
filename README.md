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
# suidex-backend
