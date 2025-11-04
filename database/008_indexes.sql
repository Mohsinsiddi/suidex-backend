-- ============================================================================
-- Performance Indexes
-- ============================================================================

-- Core tables
CREATE INDEX idx_tokens_symbol ON tokens(symbol);
CREATE INDEX idx_tokens_search ON tokens USING GIN(search_vector);

CREATE INDEX idx_pairs_token0 ON pairs(token0_address);
CREATE INDEX idx_pairs_token1 ON pairs(token1_address);
CREATE INDEX idx_pairs_active ON pairs(is_active) WHERE is_active = TRUE;

CREATE INDEX idx_users_ens ON users(ens_name) WHERE ens_name IS NOT NULL;

CREATE INDEX idx_farm_pools_type ON farm_pools(pool_type);
CREATE INDEX idx_farm_pools_active ON farm_pools(is_active) WHERE is_active = TRUE;

CREATE INDEX idx_locker_epochs_number ON locker_epochs(epoch_number);
CREATE INDEX idx_locker_epochs_claimable ON locker_epochs(is_claimable) WHERE is_claimable = TRUE;

-- Swap events
CREATE INDEX idx_swap_pair_time ON swap_events(pair_id, event_time DESC);
CREATE INDEX idx_swap_sender_time ON swap_events(sender_address, event_time DESC);
CREATE INDEX idx_swap_tx ON swap_events(tx_hash);
CREATE INDEX idx_swap_block ON swap_events(block_number DESC);
CREATE INDEX idx_swap_volume ON swap_events(total_volume_usd DESC) WHERE total_volume_usd > 1000;

-- LP events
CREATE INDEX idx_lp_mint_pair_time ON lp_mint_events(pair_id, event_time DESC);
CREATE INDEX idx_lp_mint_sender ON lp_mint_events(sender_address, event_time DESC);
CREATE INDEX idx_lp_mint_coin ON lp_mint_events(lp_coin_id);

CREATE INDEX idx_lp_burn_pair_time ON lp_burn_events(pair_id, event_time DESC);
CREATE INDEX idx_lp_burn_sender ON lp_burn_events(sender_address, event_time DESC);
CREATE INDEX idx_lp_burn_coin ON lp_burn_events(lp_coin_id);

-- Sync events
CREATE INDEX idx_sync_pair_time ON sync_events(pair_id, event_time DESC);

-- Farm events
CREATE INDEX idx_farm_staked_pool_time ON farm_staked_events(pool_id, event_time DESC);
CREATE INDEX idx_farm_staked_user ON farm_staked_events(staker_address, event_time DESC);
CREATE INDEX idx_farm_staked_position ON farm_staked_events(position_id);

CREATE INDEX idx_farm_unstaked_pool_time ON farm_unstaked_events(pool_id, event_time DESC);
CREATE INDEX idx_farm_unstaked_user ON farm_unstaked_events(staker_address, event_time DESC);
CREATE INDEX idx_farm_unstaked_position ON farm_unstaked_events(position_id);

CREATE INDEX idx_farm_reward_pool_time ON farm_reward_claimed_events(pool_id, event_time DESC);
CREATE INDEX idx_farm_reward_user ON farm_reward_claimed_events(staker_address, event_time DESC);

-- Locker events
CREATE INDEX idx_locker_locked_user ON locker_locked_events(user_address, event_time DESC);
CREATE INDEX idx_locker_locked_lock_id ON locker_locked_events(lock_id);

CREATE INDEX idx_locker_unlocked_user ON locker_unlocked_events(user_address, event_time DESC);
CREATE INDEX idx_locker_unlocked_lock_id ON locker_unlocked_events(lock_id);

CREATE INDEX idx_locker_victory_user ON locker_victory_claimed_events(user_address, event_time DESC);
CREATE INDEX idx_locker_victory_lock_id ON locker_victory_claimed_events(lock_id);

CREATE INDEX idx_locker_sui_user ON locker_sui_claimed_events(user_address, event_time DESC);
CREATE INDEX idx_locker_sui_lock_id ON locker_sui_claimed_events(lock_id);
CREATE INDEX idx_locker_sui_epoch ON locker_sui_claimed_events(epoch_id);

-- Positions
CREATE INDEX idx_lp_positions_owner ON lp_positions(owner_address);
CREATE INDEX idx_lp_positions_pair ON lp_positions(pair_id);
CREATE INDEX idx_lp_positions_status ON lp_positions(status);
CREATE INDEX idx_lp_positions_coin ON lp_positions(lp_coin_id);

CREATE INDEX idx_farm_positions_owner ON farm_positions(owner_address);
CREATE INDEX idx_farm_positions_pool ON farm_positions(pool_id);
CREATE INDEX idx_farm_positions_status ON farm_positions(status);
CREATE INDEX idx_farm_positions_vault ON farm_positions(vault_id);

CREATE INDEX idx_locker_positions_owner ON locker_positions(owner_address);
CREATE INDEX idx_locker_positions_lock_id ON locker_positions(lock_id);
CREATE INDEX idx_locker_positions_period ON locker_positions(lock_period);
CREATE INDEX idx_locker_positions_status ON locker_positions(status);