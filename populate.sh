#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}📦 Populating Shared Package Files...${NC}\n"

# Navigate to shared package
cd packages/shared/src

# ============================================================================
# types/events.ts - All Move Event Definitions
# ============================================================================

echo -e "${YELLOW}Creating types/events.ts...${NC}"

cat > types/events.ts << 'EOF'
/**
 * Event type definitions matching Move contract structs
 * All events from pair, farm, and locker contracts
 */

// ============================================================================
// PAIR EVENTS (suitrump_dex::pair)
// ============================================================================

export interface SwapEvent {
  sender: string;
  amount0_in: string; // u256 as string
  amount1_in: string;
  amount0_out: string;
  amount1_out: string;
}

export interface LPMintEvent {
  sender: string;
  lp_coin_id: string; // ID as string
  token0_type: string; // TypeName as string
  token1_type: string;
  amount0: string; // u256 as string
  amount1: string;
  liquidity: string;
  total_supply: string;
}

export interface LPBurnEvent {
  sender: string;
  lp_coin_id: string;
  token0_type: string;
  token1_type: string;
  amount0: string;
  amount1: string;
  liquidity: string;
  total_supply: string;
}

export interface SyncEvent {
  reserve0: string; // u256 as string
  reserve1: string;
}

// ============================================================================
// FACTORY EVENTS (suitrump_dex::factory)
// ============================================================================

export interface PairCreatedEvent {
  token0: string; // TypeName as string
  token1: string;
  pair: string; // address
  pair_len: string; // u64 as string
}

// ============================================================================
// FARM EVENTS (suitrump_dex::farm)
// ============================================================================

export interface StakedEvent {
  staker: string;
  pool_type: string; // TypeName as string
  amount: string; // u256 as string
  timestamp: string; // u64 as string
}

export interface UnstakedEvent {
  staker: string;
  pool_type: string;
  amount: string;
  timestamp: string;
}

export interface RewardClaimedEvent {
  staker: string;
  pool_type: string;
  amount: string;
  timestamp: string;
}

export interface PoolCreatedEvent {
  pool_type: string;
  allocation_points: string; // u256 as string
  deposit_fee: string;
  withdrawal_fee: string;
  is_native_pair: boolean;
  is_lp_token: boolean;
}

// ============================================================================
// LOCKER EVENTS (suitrump_dex::victory_token_locker)
// ============================================================================

export interface TokensLockedEvent {
  user: string;
  lock_id: string; // u64 as string
  amount: string; // u64 as string
  lock_period: string;
  lock_end: string;
}

export interface TokensUnlockedEvent {
  user: string;
  lock_id: string;
  amount: string;
  victory_rewards: string;
  sui_rewards: string;
  timestamp: string;
}

export interface VictoryRewardsClaimedEvent {
  user: string;
  lock_id: string;
  amount: string;
  timestamp: string;
  total_claimed_for_lock: string;
}

export interface PoolSUIClaimedEvent {
  user: string;
  epoch_id: string;
  lock_id: string;
  lock_period: string;
  pool_type: number; // u8
  amount_staked: string;
  sui_claimed: string;
  timestamp: string;
}

export interface EpochCreatedEvent {
  epoch_id: string;
  week_number: string;
  week_start: string;
  week_end: string;
  timestamp: string;
}

export interface WeeklyRevenueAddedEvent {
  epoch_id: string;
  week_number: string;
  amount: string;
  total_week_revenue: string;
  week_pool_sui: string;
  three_month_pool_sui: string;
  year_pool_sui: string;
  three_year_pool_sui: string;
  week_pool_total_staked: string;
  three_month_pool_total_staked: string;
  year_pool_total_staked: string;
  three_year_pool_total_staked: string;
  week_allocation_bp: string;
  three_month_allocation_bp: string;
  year_allocation_bp: string;
  three_year_allocation_bp: string;
  dynamic_allocations_used: boolean;
  timestamp: string;
}

// ============================================================================
// WRAPPER TYPE FOR SUI EVENTS
// ============================================================================

export interface ParsedSuiEvent<T> {
  id: {
    txDigest: string;
    eventSeq: string;
  };
  packageId: string;
  transactionModule: string;
  sender: string;
  type: string;
  parsedJson: T;
  timestampMs: string;
  bcs: string;
}

// ============================================================================
// EVENT TYPE UNION
// ============================================================================

export type AnyDexEvent =
  | SwapEvent
  | LPMintEvent
  | LPBurnEvent
  | SyncEvent
  | PairCreatedEvent
  | StakedEvent
  | UnstakedEvent
  | RewardClaimedEvent
  | PoolCreatedEvent
  | TokensLockedEvent
  | TokensUnlockedEvent
  | VictoryRewardsClaimedEvent
  | PoolSUIClaimedEvent
  | EpochCreatedEvent
  | WeeklyRevenueAddedEvent;

// ============================================================================
// EVENT DISCRIMINATOR
// ============================================================================

export enum EventType {
  // Pair events
  SWAP = 'Swap',
  LP_MINT = 'LPMint',
  LP_BURN = 'LPBurn',
  SYNC = 'Sync',
  PAIR_CREATED = 'PairCreated',
  
  // Farm events
  STAKED = 'Staked',
  UNSTAKED = 'Unstaked',
  REWARD_CLAIMED = 'RewardClaimed',
  POOL_CREATED = 'PoolCreated',
  
  // Locker events
  TOKENS_LOCKED = 'TokensLocked',
  TOKENS_UNLOCKED = 'TokensUnlocked',
  VICTORY_REWARDS_CLAIMED = 'VictoryRewardsClaimed',
  POOL_SUI_CLAIMED = 'PoolSUIClaimed',
  EPOCH_CREATED = 'EpochCreated',
  WEEKLY_REVENUE_ADDED = 'WeeklyRevenueAdded',
}
EOF

# ============================================================================
# types/database.ts - Database Helper Types
# ============================================================================

echo -e "${YELLOW}Creating types/database.ts...${NC}"

cat > types/database.ts << 'EOF'
/**
 * Database-specific type definitions
 * Enums, statuses, and helper types for DB operations
 */

// ============================================================================
// ENUMS
// ============================================================================

export enum PositionStatus {
  ACTIVE = 'active',
  CLOSED = 'closed',
}

export enum ContractType {
  PAIR = 'pair',
  FARM = 'farm',
  LOCKER = 'locker',
}

export enum LockPeriod {
  WEEK = 'week',
  THREE_MONTH = 'three_month',
  YEAR = 'year',
  THREE_YEAR = 'three_year',
}

export enum TxStatus {
  SUCCESS = 'success',
  FAILED = 'failed',
  PENDING = 'pending',
}

export enum PoolType {
  LP = 'lp',
  SINGLE = 'single',
}

// ============================================================================
// DATABASE ROW TYPES
// ============================================================================

export interface TokenRow {
  id: number;
  address: string;
  symbol: string;
  name: string;
  decimals: number;
  created_at: Date;
  updated_at: Date;
}

export interface PairRow {
  id: number;
  address: string;
  token0_address: string;
  token1_address: string;
  reserve0: string;
  reserve1: string;
  total_supply: string;
  created_at: Date;
  updated_at: Date;
}

export interface LPPositionRow {
  id: number;
  lp_coin_id: string;
  user_address: string;
  pair_id: number;
  token0_address: string;
  token1_address: string;
  liquidity_amount: string;
  token0_amount: string;
  token1_amount: string;
  status: PositionStatus;
  opened_at: Date;
  closed_at?: Date;
}

export interface FarmPositionRow {
  id: number;
  user_address: string;
  farm_pool_id: number;
  pool_type: string;
  staked_amount: string;
  rewards_claimed: string;
  status: PositionStatus;
  opened_at: Date;
  closed_at?: Date;
}

export interface LockerPositionRow {
  id: number;
  user_address: string;
  lock_id: string;
  amount: string;
  lock_period: LockPeriod;
  lock_end: Date;
  victory_rewards_claimed: string;
  sui_rewards_claimed: string;
  status: PositionStatus;
  opened_at: Date;
  closed_at?: Date;
}

export interface CheckpointRow {
  id: number;
  contract_type: ContractType;
  checkpoint: string;
  last_tx_digest: string;
  updated_at: Date;
}

// ============================================================================
// BATCH INSERT TYPES
// ============================================================================

export interface BatchInsertResult {
  inserted: number;
  failed: number;
  errors: Error[];
}

export interface InsertOptions {
  onConflict?: 'ignore' | 'update';
  batchSize?: number;
}

// ============================================================================
// QUERY FILTER TYPES
// ============================================================================

export interface PaginationParams {
  limit: number;
  offset: number;
}

export interface TimeRangeFilter {
  start?: Date;
  end?: Date;
}

export interface UserFilter {
  address: string;
  status?: PositionStatus;
}
EOF

# ============================================================================
# constants.ts - Contract Addresses & Configuration
# ============================================================================

echo -e "${YELLOW}Creating constants.ts...${NC}"

cat > constants.ts << 'EOF'
/**
 * Global constants and configuration
 * Contract addresses, decimals, and event type mappings
 */

// ============================================================================
// CONTRACT ADDRESSES (Update these with your deployed contracts!)
// ============================================================================

export const CONTRACTS = {
  PAIR_PACKAGE_ID: process.env.PAIR_PACKAGE_ID || '0x50c2216a078d3bdf5081fe436df9f42dfdbe538ebd9c935913ce2436362cff90',
  FARM_PACKAGE_ID: process.env.FARM_PACKAGE_ID || '0x3f4ae88398b5a250a2ce44484a9420c1645c189a949e8b89e57f6e03bfc235ce',
  LOCKER_PACKAGE_ID: process.env.LOCKER_PACKAGE_ID || '0xac4c650543b6360f56be83f973b458037b77fcd3c7fbe23bfc422c830a2d91e9',
} as const;

// ============================================================================
// TOKEN DECIMALS
// ============================================================================

export const DECIMALS = {
  SUI: 9,
  VICTORY: 6,
  USDC: 6,
  USDT: 6,
  DEFAULT: 6,
} as const;

// ============================================================================
// EVENT TYPE STRINGS (For Sui event filtering)
// ============================================================================

export const EVENT_TYPES = {
  // Pair events
  SWAP: (pkg: string) => `${pkg}::pair::Swap`,
  LP_MINT: (pkg: string) => `${pkg}::pair::LPMint`,
  LP_BURN: (pkg: string) => `${pkg}::pair::LPBurn`,
  SYNC: (pkg: string) => `${pkg}::pair::Sync`,
  PAIR_CREATED: (pkg: string) => `${pkg}::factory::PairCreated`,
  
  // Farm events
  STAKED: (pkg: string) => `${pkg}::farm::Staked`,
  UNSTAKED: (pkg: string) => `${pkg}::farm::Unstaked`,
  REWARD_CLAIMED: (pkg: string) => `${pkg}::farm::RewardClaimed`,
  POOL_CREATED: (pkg: string) => `${pkg}::farm::PoolCreated`,
  
  // Locker events
  TOKENS_LOCKED: (pkg: string) => `${pkg}::victory_token_locker::TokensLocked`,
  TOKENS_UNLOCKED: (pkg: string) => `${pkg}::victory_token_locker::TokensUnlocked`,
  VICTORY_REWARDS_CLAIMED: (pkg: string) => `${pkg}::victory_token_locker::VictoryRewardsClaimed`,
  POOL_SUI_CLAIMED: (pkg: string) => `${pkg}::victory_token_locker::PoolSUIClaimed`,
  EPOCH_CREATED: (pkg: string) => `${pkg}::victory_token_locker::EpochCreated`,
  WEEKLY_REVENUE_ADDED: (pkg: string) => `${pkg}::victory_token_locker::WeeklyRevenueAdded`,
} as const;

// ============================================================================
// KNOWN TOKEN ADDRESSES (Add as you discover them)
// ============================================================================

export const KNOWN_TOKENS: Record<string, { symbol: string; decimals: number }> = {
  '0x2::sui::SUI': { symbol: 'SUI', decimals: 9 },
  // Add Victory token address when known
  // Add other tokens as discovered
};

// ============================================================================
// DATABASE CONFIGURATION
// ============================================================================

export const DB_CONFIG = {
  BATCH_SIZE: 100, // Insert in batches of 100 events
  MAX_RETRIES: 3,
  RETRY_DELAY_MS: 1000,
} as const;

// ============================================================================
// INDEXER CONFIGURATION
// ============================================================================

export const INDEXER_CONFIG = {
  CHECKPOINT_INTERVAL_MS: 5000, // Save checkpoint every 5 seconds
  EVENT_BATCH_SIZE: 50, // Process 50 events at a time
  MAX_EVENTS_PER_QUERY: 1000,
} as const;

// ============================================================================
// HELPER FUNCTIONS
// ============================================================================

/**
 * Extract event name from full type string
 * Example: "0xabc::pair::Swap<0x2::sui::SUI, 0x123::token::USDC>" -> "Swap"
 */
export function extractEventName(fullType: string): string {
  const match = fullType.match(/::(\w+)(?:<|$)/);
  return match ? match[1] : '';
}

/**
 * Extract package ID from event type
 * Example: "0xabc::pair::Swap" -> "0xabc"
 */
export function extractPackageId(fullType: string): string {
  const match = fullType.match(/^(0x[a-fA-F0-9]+)::/);
  return match ? match[1] : '';
}

/**
 * Determine contract type from package ID
 */
export function getContractType(packageId: string): 'pair' | 'farm' | 'locker' | null {
  if (packageId === CONTRACTS.PAIR_PACKAGE_ID) return 'pair';
  if (packageId === CONTRACTS.FARM_PACKAGE_ID) return 'farm';
  if (packageId === CONTRACTS.LOCKER_PACKAGE_ID) return 'locker';
  return null;
}
EOF

# ============================================================================
# index.ts - Export everything
# ============================================================================

echo -e "${YELLOW}Creating index.ts...${NC}"

cat > index.ts << 'EOF'
/**
 * Shared package exports
 * Types, constants, and utilities used across indexer and API
 */

// Event types
export * from './types/events';

// Database types
export * from './types/database';

// Constants and helpers
export * from './constants';
EOF

echo -e "${GREEN}✅ Shared package files populated!${NC}\n"

# Navigate back to root
cd ../../..

echo -e "${YELLOW}📋 Files created:${NC}"
echo "  ✓ packages/shared/src/types/events.ts (15 event types)"
echo "  ✓ packages/shared/src/types/database.ts (enums + row types)"
echo "  ✓ packages/shared/src/constants.ts (contract addresses + helpers)"
echo "  ✓ packages/shared/src/index.ts (exports)"

echo -e "\n${GREEN}🎉 Ready to use shared types in indexer!${NC}"