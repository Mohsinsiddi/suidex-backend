import { sql } from './client';

export async function upsertToken(params: {
  address: string;
  symbol: string;
  name: string;
  decimals: number;
}): Promise<void> {
  await sql`
    INSERT INTO tokens (address, symbol, name, decimals)
    VALUES (${params.address}, ${params.symbol}, ${params.name}, ${params.decimals})
    ON CONFLICT (address) 
    DO UPDATE SET symbol = EXCLUDED.symbol, name = EXCLUDED.name, 
      decimals = EXCLUDED.decimals, updated_at = NOW()
  `;
}

export async function upsertPair(params: {
  address: string;
  token0_address: string;
  token1_address: string;
  reserve0: string;
  reserve1: string;
}): Promise<{ id: number }> {
  const [result] = await sql<[{ id: number }]>`
    INSERT INTO pairs (address, token0_address, token1_address, reserve0, reserve1, total_supply)
    VALUES (${params.address}, ${params.token0_address}, ${params.token1_address}, 
            ${params.reserve0}, ${params.reserve1}, '0')
    ON CONFLICT (address) DO UPDATE SET reserve0 = EXCLUDED.reserve0, 
      reserve1 = EXCLUDED.reserve1, updated_at = NOW()
    RETURNING id
  `;
  return result;
}

export async function updatePairReserves(params: {
  address: string;
  reserve0: string;
  reserve1: string;
}): Promise<void> {
  await sql`
    UPDATE pairs SET reserve0 = ${params.reserve0}, reserve1 = ${params.reserve1}, updated_at = NOW()
    WHERE address = ${params.address}
  `;
}

export async function insertSwapEvent(params: {
  tx_digest: string;
  event_seq: string;
  block_number: bigint;
  event_time: Date;
  pair_address: string;
  sender: string;
  amount0_in: string;
  amount1_in: string;
  amount0_out: string;
  amount1_out: string;
  reserve0_after: string;
  reserve1_after: string;
}): Promise<void> {
  await sql`
    INSERT INTO swap_events (tx_digest, event_seq, block_number, event_time, pair_address, sender,
      amount0_in, amount1_in, amount0_out, amount1_out, reserve0_after, reserve1_after)
    VALUES (${params.tx_digest}, ${params.event_seq}, ${params.block_number.toString()}, ${params.event_time},
      ${params.pair_address}, ${params.sender}, ${params.amount0_in}, ${params.amount1_in},
      ${params.amount0_out}, ${params.amount1_out}, ${params.reserve0_after}, ${params.reserve1_after})
    ON CONFLICT (tx_digest, event_seq) DO NOTHING
  `;
}

export async function insertLPMintEvent(params: {
  tx_digest: string;
  event_seq: string;
  block_number: bigint;
  event_time: Date;
  lp_coin_id: string;
  pair_address: string;
  sender: string;
  token0_address: string;
  token1_address: string;
  amount0: string;
  amount1: string;
  liquidity: string;
  total_supply: string;
}): Promise<void> {
  await sql`
    INSERT INTO lp_mint_events (tx_digest, event_seq, block_number, event_time, lp_coin_id, 
      pair_address, sender, token0_address, token1_address, amount0, amount1, liquidity, total_supply)
    VALUES (${params.tx_digest}, ${params.event_seq}, ${params.block_number.toString()}, ${params.event_time},
      ${params.lp_coin_id}, ${params.pair_address}, ${params.sender}, ${params.token0_address},
      ${params.token1_address}, ${params.amount0}, ${params.amount1}, ${params.liquidity}, ${params.total_supply})
    ON CONFLICT (tx_digest, event_seq) DO NOTHING
  `;
}

export async function insertLPBurnEvent(params: {
  tx_digest: string;
  event_seq: string;
  block_number: bigint;
  event_time: Date;
  lp_coin_id: string;
  pair_address: string;
  sender: string;
  token0_address: string;
  token1_address: string;
  amount0: string;
  amount1: string;
  liquidity: string;
  total_supply: string;
}): Promise<void> {
  await sql`
    INSERT INTO lp_burn_events (tx_digest, event_seq, block_number, event_time, lp_coin_id,
      pair_address, sender, token0_address, token1_address, amount0, amount1, liquidity, total_supply)
    VALUES (${params.tx_digest}, ${params.event_seq}, ${params.block_number.toString()}, ${params.event_time},
      ${params.lp_coin_id}, ${params.pair_address}, ${params.sender}, ${params.token0_address},
      ${params.token1_address}, ${params.amount0}, ${params.amount1}, ${params.liquidity}, ${params.total_supply})
    ON CONFLICT (tx_digest, event_seq) DO NOTHING
  `;
}

export async function insertSyncEvent(params: {
  tx_digest: string;
  event_seq: string;
  block_number: bigint;
  event_time: Date;
  pair_address: string;
  reserve0: string;
  reserve1: string;
}): Promise<void> {
  await sql`
    INSERT INTO sync_events (tx_digest, event_seq, block_number, event_time, pair_address, reserve0, reserve1)
    VALUES (${params.tx_digest}, ${params.event_seq}, ${params.block_number.toString()}, ${params.event_time},
      ${params.pair_address}, ${params.reserve0}, ${params.reserve1})
    ON CONFLICT (tx_digest, event_seq) DO NOTHING
  `;
}

export async function insertFarmStakedEvent(params: {
  tx_digest: string;
  event_seq: string;
  block_number: bigint;
  event_time: Date;
  staker: string;
  pool_type: string;
  amount: string;
  timestamp: string;
}): Promise<void> {
  await sql`
    INSERT INTO farm_staked_events (tx_digest, event_seq, block_number, event_time, staker, pool_type, amount, timestamp)
    VALUES (${params.tx_digest}, ${params.event_seq}, ${params.block_number.toString()}, ${params.event_time},
      ${params.staker}, ${params.pool_type}, ${params.amount}, ${params.timestamp})
    ON CONFLICT (tx_digest, event_seq) DO NOTHING
  `;
}

export async function insertFarmUnstakedEvent(params: {
  tx_digest: string;
  event_seq: string;
  block_number: bigint;
  event_time: Date;
  staker: string;
  pool_type: string;
  amount: string;
  timestamp: string;
}): Promise<void> {
  await sql`
    INSERT INTO farm_unstaked_events (tx_digest, event_seq, block_number, event_time, staker, pool_type, amount, timestamp)
    VALUES (${params.tx_digest}, ${params.event_seq}, ${params.block_number.toString()}, ${params.event_time},
      ${params.staker}, ${params.pool_type}, ${params.amount}, ${params.timestamp})
    ON CONFLICT (tx_digest, event_seq) DO NOTHING
  `;
}

export async function insertFarmRewardClaimedEvent(params: {
  tx_digest: string;
  event_seq: string;
  block_number: bigint;
  event_time: Date;
  staker: string;
  pool_type: string;
  amount: string;
  timestamp: string;
}): Promise<void> {
  await sql`
    INSERT INTO farm_reward_claimed_events (tx_digest, event_seq, block_number, event_time, staker, pool_type, amount, timestamp)
    VALUES (${params.tx_digest}, ${params.event_seq}, ${params.block_number.toString()}, ${params.event_time},
      ${params.staker}, ${params.pool_type}, ${params.amount}, ${params.timestamp})
    ON CONFLICT (tx_digest, event_seq) DO NOTHING
  `;
}

export async function upsertFarmPool(params: {
  pool_type: string;
  allocation_points: string;
  deposit_fee_bps: number;
  withdrawal_fee_bps: number;
  is_native_pair: boolean;
  is_lp_token: boolean;
}): Promise<{ id: number }> {
  const [result] = await sql<[{ id: number }]>`
    INSERT INTO farm_pools (pool_type, allocation_points, deposit_fee_bps, withdrawal_fee_bps, is_native_pair, is_lp_token)
    VALUES (${params.pool_type}, ${params.allocation_points}, ${params.deposit_fee_bps},
      ${params.withdrawal_fee_bps}, ${params.is_native_pair}, ${params.is_lp_token})
    ON CONFLICT (pool_type) DO UPDATE SET allocation_points = EXCLUDED.allocation_points,
      deposit_fee_bps = EXCLUDED.deposit_fee_bps, withdrawal_fee_bps = EXCLUDED.withdrawal_fee_bps, updated_at = NOW()
    RETURNING id
  `;
  return result;
}

export async function insertLockerLockedEvent(params: {
  tx_digest: string;
  event_seq: string;
  block_number: bigint;
  event_time: Date;
  user: string;
  lock_id: string;
  amount: string;
  lock_period: string;
  lock_end: string;
}): Promise<void> {
  await sql`
    INSERT INTO locker_locked_events (tx_digest, event_seq, block_number, event_time, user, lock_id, amount, lock_period, lock_end)
    VALUES (${params.tx_digest}, ${params.event_seq}, ${params.block_number.toString()}, ${params.event_time},
      ${params.user}, ${params.lock_id}, ${params.amount}, ${params.lock_period}, ${params.lock_end})
    ON CONFLICT (tx_digest, event_seq) DO NOTHING
  `;
}

export async function insertLockerUnlockedEvent(params: {
  tx_digest: string;
  event_seq: string;
  block_number: bigint;
  event_time: Date;
  user: string;
  lock_id: string;
  amount: string;
  victory_rewards: string;
  sui_rewards: string;
  timestamp: string;
}): Promise<void> {
  await sql`
    INSERT INTO locker_unlocked_events (tx_digest, event_seq, block_number, event_time, user, lock_id, amount,
      victory_rewards, sui_rewards, timestamp)
    VALUES (${params.tx_digest}, ${params.event_seq}, ${params.block_number.toString()}, ${params.event_time},
      ${params.user}, ${params.lock_id}, ${params.amount}, ${params.victory_rewards},
      ${params.sui_rewards}, ${params.timestamp})
    ON CONFLICT (tx_digest, event_seq) DO NOTHING
  `;
}

export async function insertLockerVictoryClaimedEvent(params: {
  tx_digest: string;
  event_seq: string;
  block_number: bigint;
  event_time: Date;
  user: string;
  lock_id: string;
  amount: string;
  timestamp: string;
  total_claimed_for_lock: string;
}): Promise<void> {
  await sql`
    INSERT INTO locker_victory_claimed_events (tx_digest, event_seq, block_number, event_time, user, lock_id, amount,
      timestamp, total_claimed_for_lock)
    VALUES (${params.tx_digest}, ${params.event_seq}, ${params.block_number.toString()}, ${params.event_time},
      ${params.user}, ${params.lock_id}, ${params.amount}, ${params.timestamp}, ${params.total_claimed_for_lock})
    ON CONFLICT (tx_digest, event_seq) DO NOTHING
  `;
}

export async function insertLockerSUIClaimedEvent(params: {
  tx_digest: string;
  event_seq: string;
  block_number: bigint;
  event_time: Date;
  user: string;
  epoch_id: string;
  lock_id: string;
  lock_period: string;
  pool_type: number;
  amount_staked: string;
  sui_claimed: string;
  timestamp: string;
}): Promise<void> {
  await sql`
    INSERT INTO locker_sui_claimed_events (tx_digest, event_seq, block_number, event_time, user, epoch_id, lock_id,
      lock_period, pool_type, amount_staked, sui_claimed, timestamp)
    VALUES (${params.tx_digest}, ${params.event_seq}, ${params.block_number.toString()}, ${params.event_time},
      ${params.user}, ${params.epoch_id}, ${params.lock_id}, ${params.lock_period},
      ${params.pool_type}, ${params.amount_staked}, ${params.sui_claimed}, ${params.timestamp})
    ON CONFLICT (tx_digest, event_seq) DO NOTHING
  `;
}

export async function upsertLockerEpoch(params: {
  epoch_id: string;
  week_number: string;
  timestamp: string;
  week_start_timestamp: Date;
  week_end_timestamp: Date;
  total_week_revenue?: string;
  week_pool_sui?: string;
  three_month_pool_sui?: string;
  year_pool_sui?: string;
  three_year_pool_sui?: string;
  week_pool_total_staked?: string;
  three_month_pool_total_staked?: string;
  year_pool_total_staked?: string;
  three_year_pool_total_staked?: string;
  week_allocation_bp?: string;
  three_month_allocation_bp?: string;
  year_allocation_bp?: string;
  three_year_allocation_bp?: string;
  dynamic_allocations_used?: boolean;
}): Promise<{ id: number }> {
  const [result] = await sql<[{ id: number }]>`
    INSERT INTO locker_epochs (
      epoch_id, 
      epoch_number, 
      week_start_timestamp,
      week_end_timestamp,
      total_sui_revenue,
      week_allocation_bps,
      three_month_allocation_bps,
      year_allocation_bps,
      three_year_allocation_bps,
      is_claimable
    )
    VALUES (
      ${params.epoch_id}, 
      ${params.week_number}, 
      ${params.week_start_timestamp},
      ${params.week_end_timestamp},
      ${params.total_week_revenue || '0'},
      ${params.week_allocation_bp || '0'},
      ${params.three_month_allocation_bp || '0'},
      ${params.year_allocation_bp || '0'},
      ${params.three_year_allocation_bp || '0'},
      false
    )
    ON CONFLICT (epoch_id) 
    DO UPDATE SET
      total_sui_revenue = COALESCE(EXCLUDED.total_sui_revenue, locker_epochs.total_sui_revenue),
      week_allocation_bps = COALESCE(EXCLUDED.week_allocation_bps, locker_epochs.week_allocation_bps),
      three_month_allocation_bps = COALESCE(EXCLUDED.three_month_allocation_bps, locker_epochs.three_month_allocation_bps),
      year_allocation_bps = COALESCE(EXCLUDED.year_allocation_bps, locker_epochs.year_allocation_bps),
      three_year_allocation_bps = COALESCE(EXCLUDED.three_year_allocation_bps, locker_epochs.three_year_allocation_bps)
    RETURNING id
  `;
  return result;
}

export async function createLPPosition(params: {
  lp_coin_id: string;
  user_address: string;
  pair_id: number;
  token0_address: string;
  token1_address: string;
  liquidity_amount: string;
  token0_amount: string;
  token1_amount: string;
  opened_at: Date;
}): Promise<void> {
  await sql`
    INSERT INTO lp_positions (lp_coin_id, user_address, pair_id, token0_address, token1_address,
      liquidity_amount, token0_amount, token1_amount, opened_at)
    VALUES (${params.lp_coin_id}, ${params.user_address}, ${params.pair_id}, ${params.token0_address},
      ${params.token1_address}, ${params.liquidity_amount}, ${params.token0_amount},
      ${params.token1_amount}, ${params.opened_at})
    ON CONFLICT (lp_coin_id) DO NOTHING
  `;
}

export async function closeLPPosition(params: {
  lp_coin_id: string;
  closed_at: Date;
}): Promise<void> {
  await sql`
    UPDATE lp_positions SET status = 'closed', closed_at = ${params.closed_at}
    WHERE lp_coin_id = ${params.lp_coin_id} AND status = 'active'
  `;
}

export async function upsertFarmPosition(params: {
  user_address: string;
  farm_pool_id: number;
  pool_type: string;
  staked_amount: string;
  status: 'active' | 'closed';
  opened_at: Date;
  closed_at?: Date;
}): Promise<void> {
  await sql`
    INSERT INTO farm_positions (user_address, farm_pool_id, pool_type, staked_amount, status, opened_at, closed_at)
    VALUES (${params.user_address}, ${params.farm_pool_id}, ${params.pool_type}, 
      ${params.staked_amount}, ${params.status}, ${params.opened_at}, ${params.closed_at || null})
    ON CONFLICT (user_address, farm_pool_id) DO UPDATE SET staked_amount = ${params.staked_amount},
      status = ${params.status}, closed_at = ${params.closed_at || null}, updated_at = NOW()
  `;
}

export async function updateFarmPositionRewards(params: {
  user_address: string;
  farm_pool_id: number;
  rewards_claimed: string;
}): Promise<void> {
  await sql`
    UPDATE farm_positions SET rewards_claimed = rewards_claimed + ${params.rewards_claimed}::numeric, updated_at = NOW()
    WHERE user_address = ${params.user_address} AND farm_pool_id = ${params.farm_pool_id}
  `;
}

export async function createLockerPosition(params: {
  user_address: string;
  lock_id: string;
  amount: string;
  lock_period: string;
  lock_end: Date;
  opened_at: Date;
}): Promise<void> {
  await sql`
    INSERT INTO locker_positions (user_address, lock_id, amount, lock_period, lock_end, opened_at)
    VALUES (${params.user_address}, ${params.lock_id}, ${params.amount}, 
      ${params.lock_period}, ${params.lock_end}, ${params.opened_at})
    ON CONFLICT (user_address, lock_id) DO NOTHING
  `;
}

export async function updateLockerPositionRewards(params: {
  user_address: string;
  lock_id: string;
  victory_rewards_claimed?: string;
  sui_rewards_claimed?: string;
}): Promise<void> {
  if (params.victory_rewards_claimed) {
    await sql`
      UPDATE locker_positions SET victory_rewards_claimed = victory_rewards_claimed + ${params.victory_rewards_claimed}::numeric,
        updated_at = NOW() WHERE user_address = ${params.user_address} AND lock_id = ${params.lock_id}
    `;
  }
  
  if (params.sui_rewards_claimed) {
    await sql`
      UPDATE locker_positions SET sui_rewards_claimed = sui_rewards_claimed + ${params.sui_rewards_claimed}::numeric,
        updated_at = NOW() WHERE user_address = ${params.user_address} AND lock_id = ${params.lock_id}
    `;
  }
}

export async function closeLockerPosition(params: {
  user_address: string;
  lock_id: string;
  closed_at: Date;
}): Promise<void> {
  await sql`
    UPDATE locker_positions SET status = 'closed', closed_at = ${params.closed_at}
    WHERE user_address = ${params.user_address} AND lock_id = ${params.lock_id} AND status = 'active'
  `;
}

// Replace these three functions at the bottom of your queries.ts file:

export async function getCheckpoint(contractType: 'pair' | 'farm' | 'locker'): Promise<{
  checkpoint: string;
  last_tx_digest: string;
} | null> {
  const columnMap = {
    pair: { checkpoint: 'pair_checkpoint', digest: 'pair_tx_digest' },
    farm: { checkpoint: 'farm_checkpoint', digest: 'farm_tx_digest' },
    locker: { checkpoint: 'locker_checkpoint', digest: 'locker_tx_digest' },
  };
  
  const cols = columnMap[contractType];
  
  const [result] = await sql<Array<{ checkpoint: string; last_tx_digest: string }>>`
    SELECT ${sql(cols.checkpoint)} as checkpoint, ${sql(cols.digest)} as last_tx_digest 
    FROM indexer_checkpoint 
    WHERE id = 1
  `;
  
  return result || null;
}

export async function updateCheckpoint(params: {
  contract_type: 'pair' | 'farm' | 'locker';
  checkpoint: string;
  last_tx_digest: string;
}): Promise<void> {
  if (params.contract_type === 'pair') {
    await sql`
      UPDATE indexer_checkpoint 
      SET pair_checkpoint = ${params.checkpoint}, 
          pair_tx_digest = ${params.last_tx_digest},
          last_sync_at = NOW()
      WHERE id = 1
    `;
  } else if (params.contract_type === 'farm') {
    await sql`
      UPDATE indexer_checkpoint 
      SET farm_checkpoint = ${params.checkpoint}, 
          farm_tx_digest = ${params.last_tx_digest},
          last_sync_at = NOW()
      WHERE id = 1
    `;
  } else {
    await sql`
      UPDATE indexer_checkpoint 
      SET locker_checkpoint = ${params.checkpoint}, 
          locker_tx_digest = ${params.last_tx_digest},
          last_sync_at = NOW()
      WHERE id = 1
    `;
  }
}

export async function getSafeCheckpoint(): Promise<string | null> {
  const [result] = await sql<Array<{ safe_checkpoint: string | null }>>`
    SELECT LEAST(pair_checkpoint, farm_checkpoint, locker_checkpoint)::text as safe_checkpoint 
    FROM indexer_checkpoint 
    WHERE id = 1
  `;
  return result?.safe_checkpoint || null;
}