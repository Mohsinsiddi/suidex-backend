-- ============================================================================
-- Core Tables (Metadata - No Hot Data)
-- ============================================================================

-- Tokens (metadata only)
CREATE TABLE tokens (
    token_address TEXT PRIMARY KEY,
    symbol TEXT NOT NULL,
    name TEXT NOT NULL,
    decimals INTEGER NOT NULL CHECK (decimals >= 0 AND decimals <= 18),
    
    -- Static metadata only
    logo_url TEXT,
    description TEXT,
    website_url TEXT,
    
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    -- Search
    search_vector tsvector GENERATED ALWAYS AS (
        setweight(to_tsvector('english', COALESCE(symbol, '')), 'A') ||
        setweight(to_tsvector('english', COALESCE(name, '')), 'B')
    ) STORED
);

-- Pairs (config only - no reserves/prices)
CREATE TABLE pairs (
    pair_id TEXT PRIMARY KEY,
    pair_address TEXT UNIQUE NOT NULL,
    
    token0_address TEXT NOT NULL REFERENCES tokens(token_address),
    token1_address TEXT NOT NULL REFERENCES tokens(token_address),
    
    -- Fee config (immutable)
    lp_fee_bps INTEGER NOT NULL,
    team_fee_bps INTEGER NOT NULL,
    locker_fee_bps INTEGER NOT NULL,
    buyback_fee_bps INTEGER NOT NULL,
    
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_block BIGINT,
    created_tx_hash TEXT,
    
    CONSTRAINT unique_token_pair UNIQUE (token0_address, token1_address)
);

-- Fee recipient addresses (snapshot history)
CREATE TABLE fee_config_snapshots (
    config_id SERIAL PRIMARY KEY,
    effective_from_block BIGINT NOT NULL,
    effective_to_block BIGINT,
    
    team_1_address TEXT NOT NULL,
    team_2_address TEXT NOT NULL,
    dev_address TEXT NOT NULL,
    locker_address TEXT NOT NULL,
    buyback_address TEXT NOT NULL,
    
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    CONSTRAINT valid_block_range CHECK (
        effective_to_block IS NULL OR effective_to_block > effective_from_block
    )
);

CREATE INDEX idx_fee_config_blocks ON fee_config_snapshots(effective_from_block, effective_to_block);

-- Users (profile only - no stats)
CREATE TABLE users (
    user_address TEXT PRIMARY KEY,
    
    -- Profile
    ens_name TEXT,
    display_name TEXT,
    avatar_url TEXT,
    
    -- Immutable facts
    first_seen_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Farm pools (config only)
CREATE TABLE farm_pools (
    pool_id TEXT PRIMARY KEY,
    pool_type pool_type NOT NULL,
    
    token_address TEXT REFERENCES tokens(token_address),
    pair_id TEXT REFERENCES pairs(pair_id),
    
    -- Config
    allocation_points INTEGER NOT NULL,
    deposit_fee_bps INTEGER NOT NULL,
    withdrawal_fee_bps INTEGER NOT NULL,
    
    is_active BOOLEAN DEFAULT TRUE,
    is_native_pair BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    CONSTRAINT pool_has_token_or_pair CHECK (
        (token_address IS NOT NULL AND pair_id IS NULL) OR
        (token_address IS NULL AND pair_id IS NOT NULL)
    )
);

-- Locker epochs
CREATE TABLE locker_epochs (
    epoch_id INTEGER PRIMARY KEY,
    epoch_number INTEGER UNIQUE NOT NULL,
    
    week_start_timestamp TIMESTAMPTZ NOT NULL,
    week_end_timestamp TIMESTAMPTZ NOT NULL,
    
    -- SUI revenue
    total_sui_revenue NUMERIC(30, 0) DEFAULT 0,
    
    -- Pool allocations (basis points)
    week_allocation_bps INTEGER NOT NULL,
    three_month_allocation_bps INTEGER NOT NULL,
    year_allocation_bps INTEGER NOT NULL,
    three_year_allocation_bps INTEGER NOT NULL,
    
    is_claimable BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Indexer checkpoint (single row)
CREATE TABLE indexer_checkpoint (
    id INTEGER PRIMARY KEY DEFAULT 1,
    
    -- Safe global watermark (all contracts synced up to here)
    safe_checkpoint BIGINT NOT NULL,
    safe_tx_digest TEXT NOT NULL,
    safe_timestamp TIMESTAMPTZ NOT NULL,
    
    -- Per-contract working checkpoints (can be ahead of safe)
    pair_checkpoint BIGINT NOT NULL,
    pair_tx_digest TEXT NOT NULL,
    pair_event_count BIGINT DEFAULT 0,
    
    farm_checkpoint BIGINT NOT NULL,
    farm_tx_digest TEXT NOT NULL,
    farm_event_count BIGINT DEFAULT 0,
    
    locker_checkpoint BIGINT NOT NULL,
    locker_tx_digest TEXT NOT NULL,
    locker_event_count BIGINT DEFAULT 0,
    
    last_sync_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    CONSTRAINT single_row CHECK (id = 1),
    CONSTRAINT valid_checkpoints CHECK (
        pair_checkpoint >= safe_checkpoint AND
        farm_checkpoint >= safe_checkpoint AND
        locker_checkpoint >= safe_checkpoint
    )
);

-- Insert initial checkpoint
INSERT INTO indexer_checkpoint (
    safe_checkpoint, safe_tx_digest, safe_timestamp,
    pair_checkpoint, pair_tx_digest,
    farm_checkpoint, farm_tx_digest,
    locker_checkpoint, locker_tx_digest
) VALUES (
    0, '', NOW(),
    0, '',
    0, '',
    0, ''
);