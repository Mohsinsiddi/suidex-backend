#!/bin/bash

GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; RED='\033[0;31m'; NC='\033[0m'

echo -e "${GREEN}═══════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}  Populating COMPLETE Indexer (12 Files)${NC}"
echo -e "${GREEN}═══════════════════════════════════════════════════════${NC}\n"

if [ ! -d "packages/indexer" ]; then
    echo -e "${RED}❌ Run from suitrump-backend root!${NC}"; exit 1
fi

cd packages/indexer/src
mkdir -p utils db parsers services

# ============================================================================
# 1/12: utils/math.ts
# ============================================================================

echo -e "${YELLOW}[1/12] utils/math.ts${NC}"

cat > utils/math.ts << 'EOF'
export function u256ToBigInt(value: string): bigint {
  return BigInt(value);
}

export function u64ToNumber(value: string): number {
  return parseInt(value);
}

export function extractTokenAddress(typeName: string | { name: string }): string {
  if (typeof typeName === 'string') return typeName;
  return typeName.name;
}

export function calculatePercentage(part: bigint, total: bigint, decimals = 2): number {
  if (total === 0n) return 0;
  const percentage = (Number(part) / Number(total)) * 100;
  return Math.round(percentage * Math.pow(10, decimals)) / Math.pow(10, decimals);
}

export function formatTokenAmount(amount: string, decimals: number): string {
  const value = BigInt(amount);
  const divisor = BigInt(10 ** decimals);
  const whole = value / divisor;
  const fraction = value % divisor;
  return `${whole}.${fraction.toString().padStart(decimals, '0')}`;
}

export function calculateAPR(params: {
  rewardsPerSecond: bigint;
  totalStaked: bigint;
  rewardTokenPrice: number;
  stakedTokenPrice: number;
}): number {
  if (params.totalStaked === 0n) return 0;
  const secondsPerYear = 365 * 24 * 60 * 60;
  const yearlyRewards = Number(params.rewardsPerSecond) * secondsPerYear;
  const yearlyRewardsUSD = yearlyRewards * params.rewardTokenPrice;
  const totalStakedUSD = Number(params.totalStaked) * params.stakedTokenPrice;
  if (totalStakedUSD === 0) return 0;
  return (yearlyRewardsUSD / totalStakedUSD) * 100;
}
EOF

# ============================================================================
# 2/12: db/client.ts
# ============================================================================

echo -e "${YELLOW}[2/12] db/client.ts${NC}"

cat > db/client.ts << 'EOF'
import postgres from 'postgres';
import { config } from '../config';
import { logger } from '../utils/logger';

export const sql = postgres(config.DATABASE_URL, {
  max: config.DATABASE_POOL_SIZE,
  idle_timeout: 20,
  connect_timeout: 10,
  prepare: true,
  onnotice: () => {},
  debug: config.NODE_ENV === 'development',
});

export async function testConnection(): Promise<boolean> {
  try {
    await sql`SELECT 1 as test`;
    logger.info('✅ Database connection successful');
    return true;
  } catch (error) {
    logger.error(error, '❌ Database connection failed');
    return false;
  }
}

export async function executeWithRetry<T>(
  queryFn: () => Promise<T>,
  maxRetries = 3,
  delayMs = 1000
): Promise<T> {
  let lastError: Error | null = null;
  
  for (let attempt = 1; attempt <= maxRetries; attempt++) {
    try {
      return await queryFn();
    } catch (error) {
      lastError = error as Error;
      logger.warn({ attempt, maxRetries, error: lastError.message }, 'Query failed, retrying...');
      
      if (attempt < maxRetries) {
        await new Promise(resolve => setTimeout(resolve, delayMs * attempt));
      }
    }
  }
  
  throw lastError;
}

export async function closeConnection(): Promise<void> {
  await sql.end({ timeout: 5 });
  logger.info('Database connection closed');
}

process.on('SIGTERM', closeConnection);
process.on('SIGINT', closeConnection);
EOF

# ============================================================================
# 3/12: db/queries.ts (LARGE FILE - CORRECT SQL SYNTAX)
# ============================================================================

echo -e "${YELLOW}[3/12] db/queries.ts (this is a big one...)${NC}"

cat > db/queries.ts << 'QUERIESEOF'
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
    VALUES (${params.tx_digest}, ${params.event_seq}, ${params.block_number}, ${params.event_time},
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
    VALUES (${params.tx_digest}, ${params.event_seq}, ${params.block_number}, ${params.event_time},
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
    VALUES (${params.tx_digest}, ${params.event_seq}, ${params.block_number}, ${params.event_time},
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
    VALUES (${params.tx_digest}, ${params.event_seq}, ${params.block_number}, ${params.event_time},
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
    VALUES (${params.tx_digest}, ${params.event_seq}, ${params.block_number}, ${params.event_time},
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
    VALUES (${params.tx_digest}, ${params.event_seq}, ${params.block_number}, ${params.event_time},
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
    VALUES (${params.tx_digest}, ${params.event_seq}, ${params.block_number}, ${params.event_time},
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
    VALUES (${params.tx_digest}, ${params.event_seq}, ${params.block_number}, ${params.event_time},
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
    VALUES (${params.tx_digest}, ${params.event_seq}, ${params.block_number}, ${params.event_time},
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
    VALUES (${params.tx_digest}, ${params.event_seq}, ${params.block_number}, ${params.event_time},
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
    VALUES (${params.tx_digest}, ${params.event_seq}, ${params.block_number}, ${params.event_time},
      ${params.user}, ${params.epoch_id}, ${params.lock_id}, ${params.lock_period},
      ${params.pool_type}, ${params.amount_staked}, ${params.sui_claimed}, ${params.timestamp})
    ON CONFLICT (tx_digest, event_seq) DO NOTHING
  `;
}

export async function upsertLockerEpoch(params: {
  epoch_id: string;
  week_number: string;
  week_start: string;
  week_end: string;
  timestamp: string;
  total_week_revenue?: string;
  week_pool_sui?: string;
  three_month_pool_sui?: string;
  year_pool_sui?: string;
  three_year_pool_sui?: string;
}): Promise<{ id: number }> {
  const [result] = await sql<[{ id: number }]>`
    INSERT INTO locker_epochs (epoch_id, week_number, week_start, week_end, timestamp,
      total_week_revenue, week_pool_sui, three_month_pool_sui, year_pool_sui, three_year_pool_sui)
    VALUES (${params.epoch_id}, ${params.week_number}, ${params.week_start}, ${params.week_end}, ${params.timestamp},
      ${params.total_week_revenue || '0'}, ${params.week_pool_sui || '0'}, 
      ${params.three_month_pool_sui || '0'}, ${params.year_pool_sui || '0'}, ${params.three_year_pool_sui || '0'})
    ON CONFLICT (epoch_id) DO UPDATE SET total_week_revenue = EXCLUDED.total_week_revenue,
      week_pool_sui = EXCLUDED.week_pool_sui, three_month_pool_sui = EXCLUDED.three_month_pool_sui,
      year_pool_sui = EXCLUDED.year_pool_sui, three_year_pool_sui = EXCLUDED.three_year_pool_sui, updated_at = NOW()
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

export async function getCheckpoint(contractType: 'pair' | 'farm' | 'locker'): Promise<{
  checkpoint: string;
  last_tx_digest: string;
} | null> {
  const [result] = await sql<Array<{ checkpoint: string; last_tx_digest: string }>>`
    SELECT checkpoint, last_tx_digest FROM indexer_checkpoints WHERE contract_type = ${contractType}
  `;
  return result || null;
}

export async function updateCheckpoint(params: {
  contract_type: 'pair' | 'farm' | 'locker';
  checkpoint: string;
  last_tx_digest: string;
}): Promise<void> {
  await sql`
    INSERT INTO indexer_checkpoints (contract_type, checkpoint, last_tx_digest)
    VALUES (${params.contract_type}, ${params.checkpoint}, ${params.last_tx_digest})
    ON CONFLICT (contract_type) DO UPDATE SET checkpoint = EXCLUDED.checkpoint,
      last_tx_digest = EXCLUDED.last_tx_digest, updated_at = NOW()
  `;
}

export async function getSafeCheckpoint(): Promise<string | null> {
  const [result] = await sql<Array<{ safe_checkpoint: string | null }>>`
    SELECT MIN(checkpoint::bigint)::text as safe_checkpoint FROM indexer_checkpoints
  `;
  return result?.safe_checkpoint || null;
}
QUERIESEOF

# ============================================================================
# 4/12: parsers/pair.ts
# ============================================================================

echo -e "${YELLOW}[4/12] parsers/pair.ts${NC}"

cat > parsers/pair.ts << 'EOF'
import type { ParsedSuiEvent, SwapEvent, LPMintEvent, LPBurnEvent, SyncEvent, PairCreatedEvent } from '@shared/types/events';
import { extractTokenAddress } from '../utils/math';

export function parseSwapEvent(event: ParsedSuiEvent<SwapEvent>) {
  return {
    tx_digest: event.id.txDigest,
    event_seq: event.id.eventSeq,
    block_number: BigInt(0),
    event_time: new Date(parseInt(event.timestampMs)),
    pair_address: event.packageId,
    sender: event.parsedJson.sender,
    amount0_in: event.parsedJson.amount0_in,
    amount1_in: event.parsedJson.amount1_in,
    amount0_out: event.parsedJson.amount0_out,
    amount1_out: event.parsedJson.amount1_out,
    reserve0_after: '0',
    reserve1_after: '0',
  };
}

export function parseLPMintEvent(event: ParsedSuiEvent<LPMintEvent>) {
  return {
    tx_digest: event.id.txDigest,
    event_seq: event.id.eventSeq,
    block_number: BigInt(0),
    event_time: new Date(parseInt(event.timestampMs)),
    lp_coin_id: event.parsedJson.lp_coin_id,
    pair_address: event.packageId,
    sender: event.parsedJson.sender,
    token0_address: extractTokenAddress(event.parsedJson.token0_type),
    token1_address: extractTokenAddress(event.parsedJson.token1_type),
    amount0: event.parsedJson.amount0,
    amount1: event.parsedJson.amount1,
    liquidity: event.parsedJson.liquidity,
    total_supply: event.parsedJson.total_supply,
  };
}

export function parseLPBurnEvent(event: ParsedSuiEvent<LPBurnEvent>) {
  return {
    tx_digest: event.id.txDigest,
    event_seq: event.id.eventSeq,
    block_number: BigInt(0),
    event_time: new Date(parseInt(event.timestampMs)),
    lp_coin_id: event.parsedJson.lp_coin_id,
    pair_address: event.packageId,
    sender: event.parsedJson.sender,
    token0_address: extractTokenAddress(event.parsedJson.token0_type),
    token1_address: extractTokenAddress(event.parsedJson.token1_type),
    amount0: event.parsedJson.amount0,
    amount1: event.parsedJson.amount1,
    liquidity: event.parsedJson.liquidity,
    total_supply: event.parsedJson.total_supply,
  };
}

export function parseSyncEvent(event: ParsedSuiEvent<SyncEvent>) {
  return {
    tx_digest: event.id.txDigest,
    event_seq: event.id.eventSeq,
    block_number: BigInt(0),
    event_time: new Date(parseInt(event.timestampMs)),
    pair_address: event.packageId,
    reserve0: event.parsedJson.reserve0,
    reserve1: event.parsedJson.reserve1,
  };
}

export function parsePairCreatedEvent(event: ParsedSuiEvent<PairCreatedEvent>) {
  return {
    pair_address: event.parsedJson.pair,
    token0_address: extractTokenAddress(event.parsedJson.token0),
    token1_address: extractTokenAddress(event.parsedJson.token1),
    created_at: new Date(parseInt(event.timestampMs)),
  };
}
EOF

# ============================================================================
# 5/12: parsers/farm.ts
# ============================================================================

echo -e "${YELLOW}[5/12] parsers/farm.ts${NC}"

cat > parsers/farm.ts << 'EOF'
import type { ParsedSuiEvent, StakedEvent, UnstakedEvent, RewardClaimedEvent, PoolCreatedEvent } from '@shared/types/events';
import { extractTokenAddress } from '../utils/math';

export function parseStakedEvent(event: ParsedSuiEvent<StakedEvent>) {
  return {
    tx_digest: event.id.txDigest,
    event_seq: event.id.eventSeq,
    block_number: BigInt(0),
    event_time: new Date(parseInt(event.timestampMs)),
    staker: event.parsedJson.staker,
    pool_type: extractTokenAddress(event.parsedJson.pool_type),
    amount: event.parsedJson.amount,
    timestamp: event.parsedJson.timestamp,
  };
}

export function parseUnstakedEvent(event: ParsedSuiEvent<UnstakedEvent>) {
  return {
    tx_digest: event.id.txDigest,
    event_seq: event.id.eventSeq,
    block_number: BigInt(0),
    event_time: new Date(parseInt(event.timestampMs)),
    staker: event.parsedJson.staker,
    pool_type: extractTokenAddress(event.parsedJson.pool_type),
    amount: event.parsedJson.amount,
    timestamp: event.parsedJson.timestamp,
  };
}

export function parseRewardClaimedEvent(event: ParsedSuiEvent<RewardClaimedEvent>) {
  return {
    tx_digest: event.id.txDigest,
    event_seq: event.id.eventSeq,
    block_number: BigInt(0),
    event_time: new Date(parseInt(event.timestampMs)),
    staker: event.parsedJson.staker,
    pool_type: extractTokenAddress(event.parsedJson.pool_type),
    amount: event.parsedJson.amount,
    timestamp: event.parsedJson.timestamp,
  };
}

export function parsePoolCreatedEvent(event: ParsedSuiEvent<PoolCreatedEvent>) {
  const depositFee = parseInt(event.parsedJson.deposit_fee) / 100;
  const withdrawalFee = parseInt(event.parsedJson.withdrawal_fee) / 100;
  
  return {
    pool_type: extractTokenAddress(event.parsedJson.pool_type),
    allocation_points: event.parsedJson.allocation_points,
    deposit_fee_bps: depositFee,
    withdrawal_fee_bps: withdrawalFee,
    is_native_pair: event.parsedJson.is_native_pair,
    is_lp_token: event.parsedJson.is_lp_token,
  };
}
EOF

# ============================================================================
# 6/12: parsers/locker.ts
# ============================================================================

echo -e "${YELLOW}[6/12] parsers/locker.ts${NC}"

cat > parsers/locker.ts << 'EOF'
import type {
  ParsedSuiEvent,
  TokensLockedEvent,
  TokensUnlockedEvent,
  VictoryRewardsClaimedEvent,
  PoolSUIClaimedEvent,
  EpochCreatedEvent,
  WeeklyRevenueAddedEvent,
} from '@shared/types/events';

export function parseTokensLockedEvent(event: ParsedSuiEvent<TokensLockedEvent>) {
  return {
    tx_digest: event.id.txDigest,
    event_seq: event.id.eventSeq,
    block_number: BigInt(0),
    event_time: new Date(parseInt(event.timestampMs)),
    user: event.parsedJson.user,
    lock_id: event.parsedJson.lock_id,
    amount: event.parsedJson.amount,
    lock_period: event.parsedJson.lock_period,
    lock_end: event.parsedJson.lock_end,
  };
}

export function parseTokensUnlockedEvent(event: ParsedSuiEvent<TokensUnlockedEvent>) {
  return {
    tx_digest: event.id.txDigest,
    event_seq: event.id.eventSeq,
    block_number: BigInt(0),
    event_time: new Date(parseInt(event.timestampMs)),
    user: event.parsedJson.user,
    lock_id: event.parsedJson.lock_id,
    amount: event.parsedJson.amount,
    victory_rewards: event.parsedJson.victory_rewards,
    sui_rewards: event.parsedJson.sui_rewards,
    timestamp: event.parsedJson.timestamp,
  };
}

export function parseVictoryRewardsClaimedEvent(event: ParsedSuiEvent<VictoryRewardsClaimedEvent>) {
  return {
    tx_digest: event.id.txDigest,
    event_seq: event.id.eventSeq,
    block_number: BigInt(0),
    event_time: new Date(parseInt(event.timestampMs)),
    user: event.parsedJson.user,
    lock_id: event.parsedJson.lock_id,
    amount: event.parsedJson.amount,
    timestamp: event.parsedJson.timestamp,
    total_claimed_for_lock: event.parsedJson.total_claimed_for_lock,
  };
}

export function parsePoolSUIClaimedEvent(event: ParsedSuiEvent<PoolSUIClaimedEvent>) {
  return {
    tx_digest: event.id.txDigest,
    event_seq: event.id.eventSeq,
    block_number: BigInt(0),
    event_time: new Date(parseInt(event.timestampMs)),
    user: event.parsedJson.user,
    epoch_id: event.parsedJson.epoch_id,
    lock_id: event.parsedJson.lock_id,
    lock_period: event.parsedJson.lock_period,
    pool_type: event.parsedJson.pool_type,
    amount_staked: event.parsedJson.amount_staked,
    sui_claimed: event.parsedJson.sui_claimed,
    timestamp: event.parsedJson.timestamp,
  };
}

export function parseEpochCreatedEvent(event: ParsedSuiEvent<EpochCreatedEvent>) {
  return {
    epoch_id: event.parsedJson.epoch_id,
    week_number: event.parsedJson.week_number,
    week_start: event.parsedJson.week_start,
    week_end: event.parsedJson.week_end,
    timestamp: event.parsedJson.timestamp,
  };
}

export function parseWeeklyRevenueAddedEvent(event: ParsedSuiEvent<WeeklyRevenueAddedEvent>) {
  return {
    epoch_id: event.parsedJson.epoch_id,
    week_number: event.parsedJson.week_number,
    total_week_revenue: event.parsedJson.total_week_revenue,
    week_pool_sui: event.parsedJson.week_pool_sui,
    three_month_pool_sui: event.parsedJson.three_month_pool_sui,
    year_pool_sui: event.parsedJson.year_pool_sui,
    three_year_pool_sui: event.parsedJson.three_year_pool_sui,
    timestamp: event.parsedJson.timestamp,
  };
}
EOF

# ============================================================================
# 7/12: services/checkpoint.ts
# ============================================================================

echo -e "${YELLOW}[7/12] services/checkpoint.ts${NC}"

cat > services/checkpoint.ts << 'EOF'
import { getCheckpoint, updateCheckpoint, getSafeCheckpoint } from '../db/queries';
import { logger } from '../utils/logger';
import type { ContractType } from '@shared/types/database';

export class CheckpointManager {
  private checkpoints: Map<ContractType, string> = new Map();

  async loadCheckpoints(): Promise<void> {
    const contracts: ContractType[] = ['pair', 'farm', 'locker'];
    
    for (const contractType of contracts) {
      const checkpoint = await getCheckpoint(contractType);
      if (checkpoint) {
        this.checkpoints.set(contractType, checkpoint.checkpoint);
        logger.info({ contractType, checkpoint: checkpoint.checkpoint }, 'Loaded checkpoint');
      } else {
        this.checkpoints.set(contractType, '0');
        logger.info({ contractType }, 'No checkpoint found, starting from 0');
      }
    }
  }

  getCheckpoint(contractType: ContractType): string {
    return this.checkpoints.get(contractType) || '0';
  }

  async getSafeResumeCheckpoint(): Promise<string> {
    const safe = await getSafeCheckpoint();
    return safe || '0';
  }

  async saveCheckpoint(params: {
    contractType: ContractType;
    checkpoint: string;
    txDigest: string;
  }): Promise<void> {
    try {
      await updateCheckpoint(params);
      this.checkpoints.set(params.contractType, params.checkpoint);
      
      logger.debug({
        contractType: params.contractType,
        checkpoint: params.checkpoint,
      }, 'Checkpoint saved');
    } catch (error) {
      logger.error({ error, params }, 'Failed to save checkpoint');
      throw error;
    }
  }

  getAllCheckpoints(): Record<string, string> {
    return {
      pair: this.checkpoints.get('pair') || '0',
      farm: this.checkpoints.get('farm') || '0',
      locker: this.checkpoints.get('locker') || '0',
    };
  }
}
EOF

# ============================================================================
# 8/12: services/price-oracle.ts (stub)
# ============================================================================

echo -e "${YELLOW}[8/12] services/price-oracle.ts${NC}"

cat > services/price-oracle.ts << 'EOF'
import { logger } from '../utils/logger';

export class PriceOracle {
  async getTokenPriceUSD(params: {
    tokenAddress: string;
    timestamp: Date;
  }): Promise<number> {
    logger.debug({ ...params }, 'Price oracle query (not implemented)');
    return 0;
  }

  calculatePriceFromReserves(params: {
    reserve0: string;
    reserve1: string;
    token0Decimals: number;
    token1Decimals: number;
  }): number {
    const r0 = BigInt(params.reserve0);
    const r1 = BigInt(params.reserve1);
    if (r0 === 0n) return 0;
    const price = Number(r1) / Number(r0);
    return price;
  }
}
EOF

# I need to split this into 2 files due to length - continuing...

echo -e "${YELLOW}Creating remaining 4 files...${NC}"

# To be continued in next response...
cd ../../..
echo -e "${GREEN}✅ Created 8/12 files. Run ./populate-indexer-ALL-part2.sh for the rest!${NC}"