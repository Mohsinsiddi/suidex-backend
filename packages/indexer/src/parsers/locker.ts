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
    timestamp: event.parsedJson.timestamp,
  };
}

export function parseWeeklyRevenueAddedEvent(event: ParsedSuiEvent<WeeklyRevenueAddedEvent>) {
  return {
    epoch_id: event.parsedJson.epoch_id,
    week_number: event.parsedJson.week_number,
    timestamp: event.parsedJson.timestamp,
    amount: event.parsedJson.amount,
    total_week_revenue: event.parsedJson.total_week_revenue,
    week_pool_sui: event.parsedJson.week_pool_sui,
    three_month_pool_sui: event.parsedJson.three_month_pool_sui,
    year_pool_sui: event.parsedJson.year_pool_sui,
    three_year_pool_sui: event.parsedJson.three_year_pool_sui,
    week_pool_total_staked: event.parsedJson.week_pool_total_staked,
    three_month_pool_total_staked: event.parsedJson.three_month_pool_total_staked,
    year_pool_total_staked: event.parsedJson.year_pool_total_staked,
    three_year_pool_total_staked: event.parsedJson.three_year_pool_total_staked,
    week_allocation_bp: event.parsedJson.week_allocation_bp,
    three_month_allocation_bp: event.parsedJson.three_month_allocation_bp,
    year_allocation_bp: event.parsedJson.year_allocation_bp,
    three_year_allocation_bp: event.parsedJson.three_year_allocation_bp,
    dynamic_allocations_used: event.parsedJson.dynamic_allocations_used,
  };
}