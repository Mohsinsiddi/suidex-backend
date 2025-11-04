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
