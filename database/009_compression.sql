-- ============================================================================
-- Compression and Retention Policies
-- ============================================================================

-- Compression after 7 days
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