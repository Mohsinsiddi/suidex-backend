-- ============================================================================
-- DEX Events (Hypertables)
-- ============================================================================

-- Swap events
CREATE TABLE swap_events (
    event_id BIGSERIAL,
    event_time TIMESTAMPTZ NOT NULL,
    
    tx_hash TEXT NOT NULL,
    block_number BIGINT NOT NULL,
    event_index INTEGER NOT NULL,
    
    pair_id TEXT NOT NULL REFERENCES pairs(pair_id),
    sender_address TEXT NOT NULL REFERENCES users(user_address) ON DELETE CASCADE,
    recipient_address TEXT, -- NULL = same as sender
    
    -- Swap amounts
    amount0_in NUMERIC(30, 0) NOT NULL DEFAULT 0,
    amount1_in NUMERIC(30, 0) NOT NULL DEFAULT 0,
    amount0_out NUMERIC(30, 0) NOT NULL DEFAULT 0,
    amount1_out NUMERIC(30, 0) NOT NULL DEFAULT 0,
    
    -- USD values at swap time (CRITICAL!)
    amount0_in_usd NUMERIC(30, 2) NOT NULL DEFAULT 0,
    amount1_in_usd NUMERIC(30, 2) NOT NULL DEFAULT 0,
    amount0_out_usd NUMERIC(30, 2) NOT NULL DEFAULT 0,
    amount1_out_usd NUMERIC(30, 2) NOT NULL DEFAULT 0,
    total_volume_usd NUMERIC(30, 2) NOT NULL DEFAULT 0,
    
    -- Fee breakdown (token amounts)
    lp_fee_amount NUMERIC(30, 0) NOT NULL DEFAULT 0,
    team_fee_amount NUMERIC(30, 0) NOT NULL DEFAULT 0,
    locker_fee_amount NUMERIC(30, 0) NOT NULL DEFAULT 0,
    buyback_fee_amount NUMERIC(30, 0) NOT NULL DEFAULT 0,
    
    -- Fee breakdown (USD)
    lp_fee_usd NUMERIC(30, 2) NOT NULL DEFAULT 0,
    team_fee_usd NUMERIC(30, 2) NOT NULL DEFAULT 0,
    locker_fee_usd NUMERIC(30, 2) NOT NULL DEFAULT 0,
    buyback_fee_usd NUMERIC(30, 2) NOT NULL DEFAULT 0,
    total_fee_usd NUMERIC(30, 2) NOT NULL DEFAULT 0,
    
    -- Swap metadata
    is_token0_to_token1 BOOLEAN NOT NULL,
    price_before NUMERIC(30, 18),
    price_after NUMERIC(30, 18),
    price_impact_bps INTEGER,
    
    -- Reserve state after
    reserve0_after NUMERIC(30, 0),
    reserve1_after NUMERIC(30, 0),
    
    status tx_status DEFAULT 'success',
    gas_used BIGINT,
    
    PRIMARY KEY (event_time, event_id)
);

SELECT create_hypertable('swap_events', 'event_time', 
    chunk_time_interval => INTERVAL '7 days',
    if_not_exists => TRUE
);

-- LP mint events
CREATE TABLE lp_mint_events (
    event_id BIGSERIAL,
    event_time TIMESTAMPTZ NOT NULL,
    
    tx_hash TEXT NOT NULL,
    block_number BIGINT NOT NULL,
    event_index INTEGER NOT NULL,
    
    pair_id TEXT NOT NULL REFERENCES pairs(pair_id),
    sender_address TEXT NOT NULL REFERENCES users(user_address) ON DELETE CASCADE,
    
    lp_coin_id TEXT NOT NULL,
    liquidity NUMERIC(30, 0) NOT NULL,
    
    amount0 NUMERIC(30, 0) NOT NULL,
    amount1 NUMERIC(30, 0) NOT NULL,
    
    -- USD values at mint time
    amount0_usd NUMERIC(30, 2) NOT NULL,
    amount1_usd NUMERIC(30, 2) NOT NULL,
    total_value_usd NUMERIC(30, 2) NOT NULL,
    
    -- Token prices
    token0_price_usd NUMERIC(30, 18),
    token1_price_usd NUMERIC(30, 18),
    
    status tx_status DEFAULT 'success',
    
    PRIMARY KEY (event_time, event_id)
);

SELECT create_hypertable('lp_mint_events', 'event_time',
    chunk_time_interval => INTERVAL '7 days',
    if_not_exists => TRUE
);

-- LP burn events
CREATE TABLE lp_burn_events (
    event_id BIGSERIAL,
    event_time TIMESTAMPTZ NOT NULL,
    
    tx_hash TEXT NOT NULL,
    block_number BIGINT NOT NULL,
    event_index INTEGER NOT NULL,
    
    pair_id TEXT NOT NULL REFERENCES pairs(pair_id),
    sender_address TEXT NOT NULL REFERENCES users(user_address) ON DELETE CASCADE,
    
    lp_coin_id TEXT NOT NULL,
    liquidity NUMERIC(30, 0) NOT NULL,
    
    amount0 NUMERIC(30, 0) NOT NULL,
    amount1 NUMERIC(30, 0) NOT NULL,
    
    -- USD values at burn time
    amount0_usd NUMERIC(30, 2) NOT NULL,
    amount1_usd NUMERIC(30, 2) NOT NULL,
    total_value_usd NUMERIC(30, 2) NOT NULL,
    
    -- Token prices
    token0_price_usd NUMERIC(30, 18),
    token1_price_usd NUMERIC(30, 18),
    
    position_duration_seconds BIGINT,
    
    status tx_status DEFAULT 'success',
    
    PRIMARY KEY (event_time, event_id)
);

SELECT create_hypertable('lp_burn_events', 'event_time',
    chunk_time_interval => INTERVAL '7 days',
    if_not_exists => TRUE
);

-- Sync events (reserve updates - source of truth for current state)
CREATE TABLE sync_events (
    event_id BIGSERIAL,
    event_time TIMESTAMPTZ NOT NULL,
    
    tx_hash TEXT NOT NULL,
    block_number BIGINT NOT NULL,
    
    pair_id TEXT NOT NULL REFERENCES pairs(pair_id),
    
    reserve0 NUMERIC(30, 0) NOT NULL,
    reserve1 NUMERIC(30, 0) NOT NULL,
    
    -- USD values (calculated)
    reserve0_usd NUMERIC(30, 2),
    reserve1_usd NUMERIC(30, 2),
    tvl_usd NUMERIC(30, 2),
    
    price NUMERIC(30, 18), -- token1 per token0
    
    PRIMARY KEY (event_time, event_id)
);

SELECT create_hypertable('sync_events', 'event_time',
    chunk_time_interval => INTERVAL '7 days',
    if_not_exists => TRUE
);