-- ============================================================================
-- Position Tracking (Current State Only)
-- ============================================================================

-- LP positions (initial state + counters)
CREATE TABLE lp_positions (
    position_id TEXT PRIMARY KEY,
    lp_coin_id TEXT UNIQUE NOT NULL,
    
    owner_address TEXT NOT NULL REFERENCES users(user_address) ON DELETE CASCADE,
    pair_id TEXT NOT NULL REFERENCES pairs(pair_id),
    
    -- Immutable initial state
    liquidity NUMERIC(30, 0) NOT NULL,
    initial_amount0 NUMERIC(30, 0) NOT NULL,
    initial_amount1 NUMERIC(30, 0) NOT NULL,
    initial_value_usd NUMERIC(30, 2) NOT NULL,
    initial_price NUMERIC(30, 18),
    
    -- Counters (updated on transactions)
    fees_earned_usd NUMERIC(30, 2) DEFAULT 0,
    realized_pnl_usd NUMERIC(30, 2) DEFAULT 0,
    
    status position_status DEFAULT 'active',
    created_at TIMESTAMPTZ NOT NULL,
    closed_at TIMESTAMPTZ,
    
    mint_tx_hash TEXT,
    burn_tx_hash TEXT
);

-- Farm positions (initial state + counters)
CREATE TABLE farm_positions (
    position_id TEXT PRIMARY KEY,
    vault_id TEXT UNIQUE NOT NULL,
    
    owner_address TEXT NOT NULL REFERENCES users(user_address) ON DELETE CASCADE,
    pool_id TEXT NOT NULL REFERENCES farm_pools(pool_id),
    pool_type pool_type NOT NULL,
    
    -- Initial state
    staked_amount NUMERIC(30, 0) NOT NULL,
    staked_amount_usd NUMERIC(30, 2),
    
    -- Counters
    total_rewards_claimed NUMERIC(30, 0) DEFAULT 0,
    total_rewards_claimed_usd NUMERIC(30, 2) DEFAULT 0,
    deposit_fees_paid NUMERIC(30, 0) DEFAULT 0,
    withdrawal_fees_paid NUMERIC(30, 0) DEFAULT 0,
    
    status position_status DEFAULT 'active',
    created_at TIMESTAMPTZ NOT NULL,
    closed_at TIMESTAMPTZ,
    last_claim_at TIMESTAMPTZ,
    
    stake_tx_hash TEXT,
    unstake_tx_hash TEXT
);

-- Locker positions (lock details + claim tracking)
CREATE TABLE locker_positions (
    position_id TEXT PRIMARY KEY,
    lock_id BIGINT UNIQUE NOT NULL,
    
    owner_address TEXT NOT NULL REFERENCES users(user_address) ON DELETE CASCADE,
    
    -- Lock details
    locked_amount NUMERIC(30, 0) NOT NULL,
    locked_amount_usd NUMERIC(30, 2),
    lock_period lock_period NOT NULL,
    lock_end_timestamp TIMESTAMPTZ NOT NULL,
    
    vault_id TEXT,
    
    -- Claim tracking
    total_victory_claimed NUMERIC(30, 0) DEFAULT 0,
    total_victory_claimed_usd NUMERIC(30, 2) DEFAULT 0,
    total_sui_claimed NUMERIC(30, 0) DEFAULT 0,
    total_sui_claimed_usd NUMERIC(30, 2) DEFAULT 0,
    last_sui_epoch_claimed INTEGER DEFAULT 0,
    
    status position_status DEFAULT 'active',
    is_expired BOOLEAN GENERATED ALWAYS AS (lock_end_timestamp < NOW()) STORED,
    
    created_at TIMESTAMPTZ NOT NULL,
    closed_at TIMESTAMPTZ,
    
    lock_tx_hash TEXT,
    unlock_tx_hash TEXT
);