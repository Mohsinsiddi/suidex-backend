-- ============================================================================
-- Extensions and Configuration
-- ============================================================================

CREATE EXTENSION IF NOT EXISTS timescaledb CASCADE;
CREATE EXTENSION IF NOT EXISTS pg_trgm;
CREATE EXTENSION IF NOT EXISTS btree_gin;

SET timezone = 'UTC';

-- TimescaleDB settings
ALTER SYSTEM SET timescaledb.max_background_workers = 8;
ALTER SYSTEM SET work_mem = '256MB';
ALTER SYSTEM SET maintenance_work_mem = '1GB';
ALTER SYSTEM SET effective_cache_size = '8GB';

SELECT pg_reload_conf();