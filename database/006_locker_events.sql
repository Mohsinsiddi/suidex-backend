-- ============================================================================
-- Locker Events (Hypertables)
-- ============================================================================

-- Tokens locked events
CREATE TABLE locker_locked_events (
    event_id BIGSERIAL,
    event_time TIMESTAMPTZ NOT NULL,
    
    tx_hash TEXT NOT NULL,
    block_number BIGINT NOT NULL,
    event_index INTEGER NOT NULL,
    
    user_address TEXT NOT NULL REFERENCES users(user_address) ON DELETE CASCADE,
    lock_id BIGINT NOT NULL,
    
    amount NUMERIC(30, 0) NOT NULL,
    amount_usd NUMERIC(30, 2),
    
    lock_period lock_period NOT NULL,
    lock_end_timestamp TIMESTAMPTZ NOT NULL,
    
    vault_id TEXT,
    position_id TEXT,
    
    status tx_status DEFAULT 'success',
    
    PRIMARY KEY (event_time, event_id)
);

SELECT create_hypertable('locker_locked_events', 'event_time',
    chunk_time_interval => INTERVAL '30 days',
    if_not_exists => TRUE
);

-- Tokens unlocked events
CREATE TABLE locker_unlocked_events (
    event_id BIGSERIAL,
    event_time TIMESTAMPTZ NOT NULL,
    
    tx_hash TEXT NOT NULL,
    block_number BIGINT NOT NULL,
    event_index INTEGER NOT NULL,
    
    user_address TEXT NOT NULL REFERENCES users(user_address) ON DELETE CASCADE,
    lock_id BIGINT NOT NULL,
    
    amount NUMERIC(30, 0) NOT NULL,
    amount_usd NUMERIC(30, 2),
    
    lock_period lock_period NOT NULL,
    lock_duration_seconds BIGINT,
    
    victory_rewards NUMERIC(30, 0) DEFAULT 0,
    victory_rewards_usd NUMERIC(30, 2) DEFAULT 0,
    sui_rewards NUMERIC(30, 0) DEFAULT 0,
    sui_rewards_usd NUMERIC(30, 2) DEFAULT 0,
    
    was_early_unlock BOOLEAN DEFAULT FALSE,
    
    status tx_status DEFAULT 'success',
    
    PRIMARY KEY (event_time, event_id)
);

SELECT create_hypertable('locker_unlocked_events', 'event_time',
    chunk_time_interval => INTERVAL '30 days',
    if_not_exists => TRUE
);

-- Victory claimed events
CREATE TABLE locker_victory_claimed_events (
    event_id BIGSERIAL,
    event_time TIMESTAMPTZ NOT NULL,
    
    tx_hash TEXT NOT NULL,
    block_number BIGINT NOT NULL,
    event_index INTEGER NOT NULL,
    
    user_address TEXT NOT NULL REFERENCES users(user_address) ON DELETE CASCADE,
    lock_id BIGINT NOT NULL,
    lock_period lock_period NOT NULL,
    
    amount NUMERIC(30, 0) NOT NULL,
    amount_usd NUMERIC(30, 2),
    
    status tx_status DEFAULT 'success',
    
    PRIMARY KEY (event_time, event_id)
);

SELECT create_hypertable('locker_victory_claimed_events', 'event_time',
    chunk_time_interval => INTERVAL '30 days',
    if_not_exists => TRUE
);

-- SUI claimed events
CREATE TABLE locker_sui_claimed_events (
    event_id BIGSERIAL,
    event_time TIMESTAMPTZ NOT NULL,
    
    tx_hash TEXT NOT NULL,
    block_number BIGINT NOT NULL,
    event_index INTEGER NOT NULL,
    
    user_address TEXT NOT NULL REFERENCES users(user_address) ON DELETE CASCADE,
    lock_id BIGINT NOT NULL,
    lock_period lock_period NOT NULL,
    epoch_id INTEGER NOT NULL REFERENCES locker_epochs(epoch_id),
    
    amount_staked NUMERIC(30, 0) NOT NULL,
    sui_claimed NUMERIC(30, 0) NOT NULL,
    sui_claimed_usd NUMERIC(30, 2),
    
    status tx_status DEFAULT 'success',
    
    PRIMARY KEY (event_time, event_id)
);

SELECT create_hypertable('locker_sui_claimed_events', 'event_time',
    chunk_time_interval => INTERVAL '30 days',
    if_not_exists => TRUE
);