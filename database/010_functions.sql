-- ============================================================================
-- Utility Functions
-- ============================================================================

-- Get fee config for a block
CREATE OR REPLACE FUNCTION get_fee_config_for_block(block_num BIGINT)
RETURNS TABLE (
    team_1_address TEXT,
    team_2_address TEXT,
    dev_address TEXT,
    locker_address TEXT,
    buyback_address TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        fc.team_1_address,
        fc.team_2_address,
        fc.dev_address,
        fc.locker_address,
        fc.buyback_address
    FROM fee_config_snapshots fc
    WHERE fc.effective_from_block <= block_num
    AND (fc.effective_to_block IS NULL OR fc.effective_to_block > block_num)
    ORDER BY fc.effective_from_block DESC
    LIMIT 1;
END;
$$ LANGUAGE plpgsql STABLE;

-- Get current pair state (from latest sync)
CREATE OR REPLACE FUNCTION get_pair_current_state(p_pair_id TEXT)
RETURNS TABLE (
    reserve0 NUMERIC,
    reserve1 NUMERIC,
    price NUMERIC,
    tvl_usd NUMERIC,
    last_update TIMESTAMPTZ
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        s.reserve0,
        s.reserve1,
        s.price,
        s.tvl_usd,
        s.event_time
    FROM sync_events s
    WHERE s.pair_id = p_pair_id
    ORDER BY s.event_time DESC
    LIMIT 1;
END;
$$ LANGUAGE plpgsql STABLE;

-- Calculate user trading stats
CREATE OR REPLACE FUNCTION get_user_trading_stats(
    p_user_address TEXT,
    p_since TIMESTAMPTZ DEFAULT NOW() - INTERVAL '24 hours'
)
RETURNS TABLE (
    total_swaps BIGINT,
    total_volume_usd NUMERIC,
    total_fees_paid_usd NUMERIC,
    unique_pairs BIGINT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        COUNT(*) as total_swaps,
        SUM(s.total_volume_usd) as total_volume_usd,
        SUM(s.total_fee_usd) as total_fees_paid_usd,
        COUNT(DISTINCT s.pair_id) as unique_pairs
    FROM swap_events s
    WHERE s.sender_address = p_user_address
    AND s.event_time >= p_since
    AND s.status = 'success';
END;
$$ LANGUAGE plpgsql STABLE;

-- Calculate pair 24h volume
CREATE OR REPLACE FUNCTION get_pair_volume_24h(p_pair_id TEXT)
RETURNS NUMERIC AS $$
DECLARE
    volume NUMERIC;
BEGIN
    SELECT COALESCE(SUM(total_volume_usd), 0)
    INTO volume
    FROM swap_events
    WHERE pair_id = p_pair_id
    AND event_time >= NOW() - INTERVAL '24 hours'
    AND status = 'success';
    
    RETURN volume;
END;
$$ LANGUAGE plpgsql STABLE;

-- Update checkpoint helper
CREATE OR REPLACE FUNCTION update_indexer_checkpoint(
    p_contract_type TEXT,
    p_checkpoint BIGINT,
    p_tx_digest TEXT
)
RETURNS VOID AS $$
BEGIN
    IF p_contract_type = 'pair' THEN
        UPDATE indexer_checkpoint SET
            pair_checkpoint = p_checkpoint,
            pair_tx_digest = p_tx_digest,
            pair_event_count = pair_event_count + 1,
            last_sync_at = NOW()
        WHERE id = 1;
    ELSIF p_contract_type = 'farm' THEN
        UPDATE indexer_checkpoint SET
            farm_checkpoint = p_checkpoint,
            farm_tx_digest = p_tx_digest,
            farm_event_count = farm_event_count + 1,
            last_sync_at = NOW()
        WHERE id = 1;
    ELSIF p_contract_type = 'locker' THEN
        UPDATE indexer_checkpoint SET
            locker_checkpoint = p_checkpoint,
            locker_tx_digest = p_tx_digest,
            locker_event_count = locker_event_count + 1,
            last_sync_at = NOW()
        WHERE id = 1;
    END IF;
    
    -- Update safe checkpoint if all are caught up
    UPDATE indexer_checkpoint SET
        safe_checkpoint = LEAST(pair_checkpoint, farm_checkpoint, locker_checkpoint),
        safe_tx_digest = CASE 
            WHEN LEAST(pair_checkpoint, farm_checkpoint, locker_checkpoint) = pair_checkpoint THEN pair_tx_digest
            WHEN LEAST(pair_checkpoint, farm_checkpoint, locker_checkpoint) = farm_checkpoint THEN farm_tx_digest
            ELSE locker_tx_digest
        END,
        safe_timestamp = NOW()
    WHERE id = 1;
END;
$$ LANGUAGE plpgsql;