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
