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
