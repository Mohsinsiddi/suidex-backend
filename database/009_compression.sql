-- ============================================================================
-- Compression and Retention Policies
-- ============================================================================

-- Enable compression on hypertables FIRST
ALTER TABLE swap_events SET (
  timescaledb.compress,
  timescaledb.compress_segmentby = 'pair_id'
);

ALTER TABLE lp_mint_events SET (timescaledb.compress);
ALTER TABLE lp_burn_events SET (timescaledb.compress);

ALTER TABLE sync_events SET (
  timescaledb.compress,
  timescaledb.compress_segmentby = 'pair_id'
);

ALTER TABLE farm_staked_events SET (
  timescaledb.compress,
  timescaledb.compress_segmentby = 'pool_id'
);

ALTER TABLE farm_unstaked_events SET (
  timescaledb.compress,
  timescaledb.compress_segmentby = 'pool_id'
);

ALTER TABLE farm_reward_claimed_events SET (
  timescaledb.compress,
  timescaledb.compress_segmentby = 'pool_id'
);

ALTER TABLE locker_locked_events SET (timescaledb.compress);
ALTER TABLE locker_unlocked_events SET (timescaledb.compress);
ALTER TABLE locker_victory_claimed_events SET (timescaledb.compress);
ALTER TABLE locker_sui_claimed_events SET (timescaledb.compress);

-- NOW add compression policies (compress after 7 days)
SELECT add_compression_policy('swap_events', INTERVAL '7 days', if_not_exists => TRUE);
SELECT add_compression_policy('lp_mint_events', INTERVAL '7 days', if_not_exists => TRUE);
SELECT add_compression_policy('lp_burn_events', INTERVAL '7 days', if_not_exists => TRUE);
SELECT add_compression_policy('sync_events', INTERVAL '7 days', if_not_exists => TRUE);
SELECT add_compression_policy('farm_staked_events', INTERVAL '7 days', if_not_exists => TRUE);
SELECT add_compression_policy('farm_unstaked_events', INTERVAL '7 days', if_not_exists => TRUE);
SELECT add_compression_policy('farm_reward_claimed_events', INTERVAL '7 days', if_not_exists => TRUE);
SELECT add_compression_policy('locker_locked_events', INTERVAL '7 days', if_not_exists => TRUE);
SELECT add_compression_policy('locker_unlocked_events', INTERVAL '7 days', if_not_exists => TRUE);
SELECT add_compression_policy('locker_victory_claimed_events', INTERVAL '7 days', if_not_exists => TRUE);
SELECT add_compression_policy('locker_sui_claimed_events', INTERVAL '7 days', if_not_exists => TRUE);

-- Retention: Keep raw events for 2 years
SELECT add_retention_policy('swap_events', INTERVAL '2 years', if_not_exists => TRUE);
SELECT add_retention_policy('lp_mint_events', INTERVAL '2 years', if_not_exists => TRUE);
SELECT add_retention_policy('lp_burn_events', INTERVAL '2 years', if_not_exists => TRUE);
SELECT add_retention_policy('sync_events', INTERVAL '2 years', if_not_exists => TRUE);
SELECT add_retention_policy('farm_staked_events', INTERVAL '2 years', if_not_exists => TRUE);
SELECT add_retention_policy('farm_unstaked_events', INTERVAL '2 years', if_not_exists => TRUE);
SELECT add_retention_policy('farm_reward_claimed_events', INTERVAL '2 years', if_not_exists => TRUE);
SELECT add_retention_policy('locker_locked_events', INTERVAL '2 years', if_not_exists => TRUE);
SELECT add_retention_policy('locker_unlocked_events', INTERVAL '2 years', if_not_exists => TRUE);
SELECT add_retention_policy('locker_victory_claimed_events', INTERVAL '2 years', if_not_exists => TRUE);
SELECT add_retention_policy('locker_sui_claimed_events', INTERVAL '2 years', if_not_exists => TRUE);