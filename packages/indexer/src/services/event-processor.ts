import { logger } from '../utils/logger';
import type { ParsedSuiEvent, AnyDexEvent } from '@shared/types/events';
import { extractEventName } from '@shared/constants';
import {
  parseSwapEvent,
  parseLPMintEvent,
  parseLPBurnEvent,
  parseSyncEvent,
  parsePairCreatedEvent,
} from '../parsers/pair';
import {
  parseStakedEvent,
  parseUnstakedEvent,
  parseRewardClaimedEvent,
  parsePoolCreatedEvent,
} from '../parsers/farm';
import {
  parseTokensLockedEvent,
  parseTokensUnlockedEvent,
  parseVictoryRewardsClaimedEvent,
  parsePoolSUIClaimedEvent,
  parseEpochCreatedEvent,
  parseWeeklyRevenueAddedEvent,
} from '../parsers/locker';
import * as db from '../db/queries';
import { emissionConfig } from './emission-config'; // ADD THIS IMPORT

export class EventProcessor {
  async processEvent(
    event: ParsedSuiEvent<AnyDexEvent>,
    contractType: 'pair' | 'farm' | 'locker'
  ): Promise<void> {
    const eventName = extractEventName(event.type);
    
    try {
      switch (eventName) {
        case 'Swap':
          await this.handleSwapEvent(event as any);
          break;
        case 'LPMint':
          await this.handleLPMintEvent(event as any);
          break;
        case 'LPBurn':
          await this.handleLPBurnEvent(event as any);
          break;
        case 'Sync':
          await this.handleSyncEvent(event as any);
          break;
        case 'PairCreated':
          await this.handlePairCreatedEvent(event as any);
          break;
        case 'Staked':
          await this.handleStakedEvent(event as any);
          break;
        case 'Unstaked':
          await this.handleUnstakedEvent(event as any);
          break;
        case 'RewardClaimed':
          await this.handleRewardClaimedEvent(event as any);
          break;
        case 'PoolCreated':
          await this.handlePoolCreatedEvent(event as any);
          break;
        case 'TokensLocked':
          await this.handleTokensLockedEvent(event as any);
          break;
        case 'TokensUnlocked':
          await this.handleTokensUnlockedEvent(event as any);
          break;
        case 'VictoryRewardsClaimed':
          await this.handleVictoryRewardsClaimedEvent(event as any);
          break;
        case 'PoolSUIClaimed':
          await this.handlePoolSUIClaimedEvent(event as any);
          break;
        case 'EpochCreated':
          await this.handleEpochCreatedEvent(event as any);
          break;
        case 'WeeklyRevenueAdded':
          await this.handleWeeklyRevenueAddedEvent(event as any);
          break;
        default:
          logger.warn({ eventName, type: event.type }, 'Unknown event type');
      }
    } catch (error) {
      logger.error({ error, eventName, event }, 'Failed to process event');
      throw error;
    }
  }

  private async handleSwapEvent(event: ParsedSuiEvent<any>): Promise<void> {
    const parsed = parseSwapEvent(event);
    await db.insertSwapEvent(parsed);
  }

  private async handleLPMintEvent(event: ParsedSuiEvent<any>): Promise<void> {
    const parsed = parseLPMintEvent(event);
    await db.insertLPMintEvent(parsed);
    
    const pair = await db.upsertPair({
      address: parsed.pair_address,
      token0_address: parsed.token0_address,
      token1_address: parsed.token1_address,
      reserve0: '0',
      reserve1: '0',
    });
    
    await db.createLPPosition({
      lp_coin_id: parsed.lp_coin_id,
      user_address: parsed.sender,
      pair_id: pair.id,
      token0_address: parsed.token0_address,
      token1_address: parsed.token1_address,
      liquidity_amount: parsed.liquidity,
      token0_amount: parsed.amount0,
      token1_amount: parsed.amount1,
      opened_at: parsed.event_time,
    });
  }

  private async handleLPBurnEvent(event: ParsedSuiEvent<any>): Promise<void> {
    const parsed = parseLPBurnEvent(event);
    await db.insertLPBurnEvent(parsed);
    await db.closeLPPosition({
      lp_coin_id: parsed.lp_coin_id,
      closed_at: parsed.event_time,
    });
  }

  private async handleSyncEvent(event: ParsedSuiEvent<any>): Promise<void> {
    const parsed = parseSyncEvent(event);
    await db.insertSyncEvent(parsed);
    await db.updatePairReserves({
      address: parsed.pair_address,
      reserve0: parsed.reserve0,
      reserve1: parsed.reserve1,
    });
  }

  private async handlePairCreatedEvent(event: ParsedSuiEvent<any>): Promise<void> {
    const parsed = parsePairCreatedEvent(event);
    await db.upsertPair({
      address: parsed.pair_address,
      token0_address: parsed.token0_address,
      token1_address: parsed.token1_address,
      reserve0: '0',
      reserve1: '0',
    });
  }

  private async handleStakedEvent(event: ParsedSuiEvent<any>): Promise<void> {
    const parsed = parseStakedEvent(event);
    await db.insertFarmStakedEvent(parsed);
    
    const pool = await db.upsertFarmPool({
      pool_type: parsed.pool_type,
      allocation_points: '0',
      deposit_fee_bps: 0,
      withdrawal_fee_bps: 0,
      is_native_pair: false,
      is_lp_token: true,
    });
    
    await db.upsertFarmPosition({
      user_address: parsed.staker,
      farm_pool_id: pool.id,
      pool_type: parsed.pool_type,
      staked_amount: parsed.amount,
      status: 'active',
      opened_at: parsed.event_time,
    });
  }

  private async handleUnstakedEvent(event: ParsedSuiEvent<any>): Promise<void> {
    const parsed = parseUnstakedEvent(event);
    await db.insertFarmUnstakedEvent(parsed);
    
    const pool = await db.upsertFarmPool({
      pool_type: parsed.pool_type,
      allocation_points: '0',
      deposit_fee_bps: 0,
      withdrawal_fee_bps: 0,
      is_native_pair: false,
      is_lp_token: true,
    });
    
    await db.upsertFarmPosition({
      user_address: parsed.staker,
      farm_pool_id: pool.id,
      pool_type: parsed.pool_type,
      staked_amount: '0',
      status: 'closed',
      opened_at: parsed.event_time,
      closed_at: parsed.event_time,
    });
  }

  private async handleRewardClaimedEvent(event: ParsedSuiEvent<any>): Promise<void> {
    const parsed = parseRewardClaimedEvent(event);
    await db.insertFarmRewardClaimedEvent(parsed);
    
    const pool = await db.upsertFarmPool({
      pool_type: parsed.pool_type,
      allocation_points: '0',
      deposit_fee_bps: 0,
      withdrawal_fee_bps: 0,
      is_native_pair: false,
      is_lp_token: true,
    });
    
    await db.updateFarmPositionRewards({
      user_address: parsed.staker,
      farm_pool_id: pool.id,
      rewards_claimed: parsed.amount,
    });
  }

  private async handlePoolCreatedEvent(event: ParsedSuiEvent<any>): Promise<void> {
    const parsed = parsePoolCreatedEvent(event);
    await db.upsertFarmPool(parsed);
  }

  private async handleTokensLockedEvent(event: ParsedSuiEvent<any>): Promise<void> {
    const parsed = parseTokensLockedEvent(event);
    await db.insertLockerLockedEvent(parsed);
    
    await db.createLockerPosition({
      user_address: parsed.user,
      lock_id: parsed.lock_id,
      amount: parsed.amount,
      lock_period: this.convertLockPeriod(parsed.lock_period),
      lock_end: new Date(parseInt(parsed.lock_end) * 1000),
      opened_at: parsed.event_time,
    });
  }

  private async handleTokensUnlockedEvent(event: ParsedSuiEvent<any>): Promise<void> {
    const parsed = parseTokensUnlockedEvent(event);
    await db.insertLockerUnlockedEvent(parsed);
    
    await db.closeLockerPosition({
      user_address: parsed.user,
      lock_id: parsed.lock_id,
      closed_at: parsed.event_time,
    });
  }

  private async handleVictoryRewardsClaimedEvent(event: ParsedSuiEvent<any>): Promise<void> {
    const parsed = parseVictoryRewardsClaimedEvent(event);
    await db.insertLockerVictoryClaimedEvent(parsed);
    
    await db.updateLockerPositionRewards({
      user_address: parsed.user,
      lock_id: parsed.lock_id,
      victory_rewards_claimed: parsed.amount,
    });
  }

  private async handlePoolSUIClaimedEvent(event: ParsedSuiEvent<any>): Promise<void> {
    const parsed = parsePoolSUIClaimedEvent(event);
    await db.insertLockerSUIClaimedEvent(parsed);
    
    await db.updateLockerPositionRewards({
      user_address: parsed.user,
      lock_id: parsed.lock_id,
      sui_rewards_claimed: parsed.sui_claimed,
    });
  }

  private async handleEpochCreatedEvent(event: ParsedSuiEvent<any>): Promise<void> {
    const parsed = parseEpochCreatedEvent(event);
    
    // Calculate week timestamps using emission config
    const weekNumber = parseInt(parsed.week_number);
    const timestamps = emissionConfig.calculateWeekTimestamps(weekNumber);
    
    await db.upsertLockerEpoch({
      ...parsed,
      week_start_timestamp: timestamps.week_start,
      week_end_timestamp: timestamps.week_end,
    });
  }

  private async handleWeeklyRevenueAddedEvent(event: ParsedSuiEvent<any>): Promise<void> {
    const parsed = parseWeeklyRevenueAddedEvent(event);
    
    // Calculate week timestamps using emission config
    const weekNumber = parseInt(parsed.week_number);
    const timestamps = emissionConfig.calculateWeekTimestamps(weekNumber);
    
    await db.upsertLockerEpoch({
      ...parsed,
      week_start_timestamp: timestamps.week_start,
      week_end_timestamp: timestamps.week_end,
    });
  }

  private convertLockPeriod(period: string): 'week' | 'three_month' | 'year' | 'three_year' {
    const seconds = parseInt(period);
    const WEEK = 7 * 24 * 60 * 60;
    
    if (seconds <= WEEK) return 'week';
    if (seconds <= 90 * 24 * 60 * 60) return 'three_month';
    if (seconds <= 365 * 24 * 60 * 60) return 'year';
    return 'three_year';
  }
}