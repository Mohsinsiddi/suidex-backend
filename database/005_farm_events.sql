-- ============================================================================
-- Farm Events (Hypertables)
-- ============================================================================

-- Staked events
CREATE TABLE farm_staked_events (
    event_id BIGSERIAL,
    event_time TIMESTAMPTZ NOT NULL,
    
    tx_hash TEXT NOT NULL,
    block_number BIGINT NOT NULL,
    event_index INTEGER NOT NULL,
    
    pool_id TEXT NOT NULL REFERENCES farm_pools(pool_id),
    pool_type pool_type NOT NULL,
    staker_address TEXT NOT NULL REFERENCES users(user_address) ON DELETE CASCADE,
    
    position_id TEXT NOT NULL,
    vault_id TEXT NOT NULL,
    
    amount NUMERIC(30, 0) NOT NULL,
    amount_usd NUMERIC(30, 2),
    
    deposit_fee NUMERIC(30, 0) DEFAULT 0,
    deposit_fee_usd NUMERIC(30, 2) DEFAULT 0,
    
    status tx_status DEFAULT 'success',
    
    PRIMARY KEY (event_time, event_id)
);

SELECT create_hypertable('farm_staked_events', 'event_time',
    chunk_time_interval => INTERVAL '7 days',
    if_not_exists => TRUE
);

-- Unstaked events
CREATE TABLE farm_unstaked_events (
    event_id BIGSERIAL,
    event_time TIMESTAMPTZ NOT NULL,
    
    tx_hash TEXT NOT NULL,
    block_number BIGINT NOT NULL,
    event_index INTEGER NOT NULL,
    
    pool_id TEXT NOT NULL REFERENCES farm_pools(pool_id),
    pool_type pool_type NOT NULL,
    staker_address TEXT NOT NULL REFERENCES users(user_address) ON DELETE CASCADE,
    
    position_id TEXT NOT NULL,
    vault_id TEXT NOT NULL,
    
    amount NUMERIC(30, 0) NOT NULL,
    amount_usd NUMERIC(30, 2),
    
    withdrawal_fee NUMERIC(30, 0) DEFAULT 0,
    withdrawal_fee_usd NUMERIC(30, 2) DEFAULT 0,
    
    rewards_claimed NUMERIC(30, 0) DEFAULT 0,
    rewards_claimed_usd NUMERIC(30, 2) DEFAULT 0,
    
    stake_duration_seconds BIGINT,
    
    status tx_status DEFAULT 'success',
    
    PRIMARY KEY (event_time, event_id)
);

SELECT create_hypertable('farm_unstaked_events', 'event_time',
    chunk_time_interval => INTERVAL '7 days',
    if_not_exists => TRUE
);

-- Reward claimed events
CREATE TABLE farm_reward_claimed_events (
    event_id BIGSERIAL,
    event_time TIMESTAMPTZ NOT NULL,
    
    tx_hash TEXT NOT NULL,
    block_number BIGINT NOT NULL,
    event_index INTEGER NOT NULL,
    
    pool_id TEXT NOT NULL REFERENCES farm_pools(pool_id),
    pool_type pool_type NOT NULL,
    staker_address TEXT NOT NULL REFERENCES users(user_address) ON DELETE CASCADE,
    
    position_id TEXT,
    
    amount NUMERIC(30, 0) NOT NULL,
    amount_usd NUMERIC(30, 2),
    
    status tx_status DEFAULT 'success',
    
    PRIMARY KEY (event_time, event_id)
);

SELECT create_hypertable('farm_reward_claimed_events', 'event_time',
    chunk_time_interval => INTERVAL '7 days',
    if_not_exists => TRUE
);