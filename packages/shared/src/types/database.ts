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
