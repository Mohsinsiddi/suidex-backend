#!/bin/bash

GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; RED='\033[0;31m'; NC='\033[0m'

echo -e "${GREEN}🚀 Populating Indexer Package (Part 2/2)${NC}\n"

if [ ! -d "packages/indexer/src/services" ]; then
    echo -e "${RED}❌ Run part 1 first!${NC}"; exit 1
fi

cd packages/indexer/src

# ============================================================================
# 9/12: services/event-processor.ts (BIG FILE)
# ============================================================================

echo -e "${YELLOW}[9/12] services/event-processor.ts${NC}"

cat > services/event-processor.ts << 'PROCEOF'
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
    await db.upsertLockerEpoch(parsed);
  }

  private async handleWeeklyRevenueAddedEvent(event: ParsedSuiEvent<any>): Promise<void> {
    const parsed = parseWeeklyRevenueAddedEvent(event);
    await db.upsertLockerEpoch(parsed);
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
PROCEOF

# ============================================================================
# 10/12: services/sui-client.ts (MEDIUM FILE)
# ============================================================================

echo -e "${YELLOW}[10/12] services/sui-client.ts${NC}"

cat > services/sui-client.ts << 'SUIEOF'
import { SuiClient, SuiEventFilter } from '@mysten/sui.js/client';
import { config } from '../config';
import { logger } from '../utils/logger';
import { CONTRACTS, EVENT_TYPES } from '@shared/constants';
import type { ParsedSuiEvent, AnyDexEvent } from '@shared/types/events';
import { CheckpointManager } from './checkpoint';
import { EventProcessor } from './event-processor';

export class SuiEventSubscriber {
  private client: SuiClient;
  private checkpointManager: CheckpointManager;
  private eventProcessor: EventProcessor;
  private isRunning = false;

  constructor(checkpointManager: CheckpointManager, eventProcessor: EventProcessor) {
    this.client = new SuiClient({ url: config.SUI_RPC_URL });
    this.checkpointManager = checkpointManager;
    this.eventProcessor = eventProcessor;
  }

  async start(): Promise<void> {
    this.isRunning = true;
    logger.info('🚀 Starting Sui event subscription...');

    await Promise.all([
      this.subscribeToPairEvents(),
      this.subscribeToFarmEvents(),
      this.subscribeToLockerEvents(),
    ]);

    logger.info('✅ All event subscriptions active');
  }

  private async subscribeToPairEvents(): Promise<void> {
    const filters: SuiEventFilter[] = [
      { MoveEventType: EVENT_TYPES.SWAP(CONTRACTS.PAIR_PACKAGE_ID) },
      { MoveEventType: EVENT_TYPES.LP_MINT(CONTRACTS.PAIR_PACKAGE_ID) },
      { MoveEventType: EVENT_TYPES.LP_BURN(CONTRACTS.PAIR_PACKAGE_ID) },
      { MoveEventType: EVENT_TYPES.SYNC(CONTRACTS.PAIR_PACKAGE_ID) },
      { MoveEventType: EVENT_TYPES.PAIR_CREATED(CONTRACTS.PAIR_PACKAGE_ID) },
    ];

    for (const filter of filters) {
      await this.subscribeToEvents(filter, 'pair');
    }
  }

  private async subscribeToFarmEvents(): Promise<void> {
    const filters: SuiEventFilter[] = [
      { MoveEventType: EVENT_TYPES.STAKED(CONTRACTS.FARM_PACKAGE_ID) },
      { MoveEventType: EVENT_TYPES.UNSTAKED(CONTRACTS.FARM_PACKAGE_ID) },
      { MoveEventType: EVENT_TYPES.REWARD_CLAIMED(CONTRACTS.FARM_PACKAGE_ID) },
      { MoveEventType: EVENT_TYPES.POOL_CREATED(CONTRACTS.FARM_PACKAGE_ID) },
    ];

    for (const filter of filters) {
      await this.subscribeToEvents(filter, 'farm');
    }
  }

  private async subscribeToLockerEvents(): Promise<void> {
    const filters: SuiEventFilter[] = [
      { MoveEventType: EVENT_TYPES.TOKENS_LOCKED(CONTRACTS.LOCKER_PACKAGE_ID) },
      { MoveEventType: EVENT_TYPES.TOKENS_UNLOCKED(CONTRACTS.LOCKER_PACKAGE_ID) },
      { MoveEventType: EVENT_TYPES.VICTORY_REWARDS_CLAIMED(CONTRACTS.LOCKER_PACKAGE_ID) },
      { MoveEventType: EVENT_TYPES.POOL_SUI_CLAIMED(CONTRACTS.LOCKER_PACKAGE_ID) },
      { MoveEventType: EVENT_TYPES.EPOCH_CREATED(CONTRACTS.LOCKER_PACKAGE_ID) },
      { MoveEventType: EVENT_TYPES.WEEKLY_REVENUE_ADDED(CONTRACTS.LOCKER_PACKAGE_ID) },
    ];

    for (const filter of filters) {
      await this.subscribeToEvents(filter, 'locker');
    }
  }

  private async subscribeToEvents(
    filter: SuiEventFilter,
    contractType: 'pair' | 'farm' | 'locker'
  ): Promise<void> {
    try {
      const unsubscribe = await this.client.subscribeEvent({
        filter,
        onMessage: async (event: any) => {
          await this.handleEvent(event, contractType);
        },
      });

      logger.info({ filter, contractType }, 'Event subscription active');

      process.on('SIGTERM', () => unsubscribe());
      process.on('SIGINT', () => unsubscribe());
    } catch (error) {
      logger.error({ error, filter, contractType }, 'Failed to subscribe to events');
      throw error;
    }
  }

  private async handleEvent(
    event: ParsedSuiEvent<AnyDexEvent>,
    contractType: 'pair' | 'farm' | 'locker'
  ): Promise<void> {
    try {
      await this.eventProcessor.processEvent(event, contractType);
    } catch (error) {
      logger.error({ error, event, contractType }, 'Failed to handle event');
    }
  }

  async stop(): Promise<void> {
    this.isRunning = false;
    logger.info('🛑 Stopping event subscription...');
  }
}
SUIEOF

# ============================================================================
# 11/12: Update main.ts
# ============================================================================

echo -e "${YELLOW}[11/12] main.ts${NC}"

cat > main.ts << 'MAINEOF'
import { logger } from './utils/logger';
import { config } from './config';
import { testConnection, closeConnection } from './db/client';
import { CheckpointManager } from './services/checkpoint';
import { EventProcessor } from './services/event-processor';
import { SuiEventSubscriber } from './services/sui-client';

async function main() {
  logger.info('🚀 Starting SuitrumpDEX Indexer...');
  logger.info(`Environment: ${config.NODE_ENV}`);
  logger.info(`Database: ${config.DATABASE_URL.split('@')[1]}`);
  logger.info(`Sui RPC: ${config.SUI_RPC_URL}`);
  
  const dbConnected = await testConnection();
  if (!dbConnected) {
    throw new Error('Database connection failed');
  }
  
  const checkpointManager = new CheckpointManager();
  await checkpointManager.loadCheckpoints();
  
  logger.info('Loaded checkpoints:', checkpointManager.getAllCheckpoints());
  
  const eventProcessor = new EventProcessor();
  const suiSubscriber = new SuiEventSubscriber(checkpointManager, eventProcessor);
  await suiSubscriber.start();
  
  logger.info('✅ Indexer started successfully');
  logger.info('📡 Listening for blockchain events...');
  
  const shutdown = async () => {
    logger.info('🛑 Shutting down indexer...');
    await suiSubscriber.stop();
    await closeConnection();
    logger.info('👋 Indexer stopped');
    process.exit(0);
  };
  
  process.on('SIGTERM', shutdown);
  process.on('SIGINT', shutdown);
  
  setInterval(() => {
    const checkpoints = checkpointManager.getAllCheckpoints();
    logger.debug({ checkpoints }, 'Indexer heartbeat');
  }, 30000);
}

main().catch((error) => {
  logger.error(error, '❌ Failed to start indexer');
  process.exit(1);
});
MAINEOF

# ============================================================================
# 12/12: Install dependencies
# ============================================================================

echo -e "${YELLOW}[12/12] Installing dependencies...${NC}"

cd ../..
bun install

cd packages/indexer
bun install

cd ../..

# ============================================================================
# DONE
# ============================================================================

echo -e "\n${GREEN}═══════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}   ALL 12 FILES CREATED! ✅${NC}"
echo -e "${GREEN}═══════════════════════════════════════════════════════${NC}\n"

echo -e "${YELLOW}📋 Files created:${NC}"
echo "  ✓ utils/math.ts"
echo "  ✓ db/client.ts"
echo "  ✓ db/queries.ts (with CORRECT SQL syntax)"
echo "  ✓ parsers/pair.ts"
echo "  ✓ parsers/farm.ts"
echo "  ✓ parsers/locker.ts"
echo "  ✓ services/checkpoint.ts"
echo "  ✓ services/price-oracle.ts"
echo "  ✓ services/event-processor.ts"
echo "  ✓ services/sui-client.ts"
echo "  ✓ main.ts (updated)"
echo "  ✓ Dependencies installed"

echo -e "\n${YELLOW}🚀 Next steps:${NC}"
echo "  1. Update .env with your contract addresses"
echo "  2. Run: ${GREEN}bun run dev:indexer${NC}"
echo "  3. Check logs for event subscription"

echo -e "\n${GREEN}Done! 🎉${NC}\n"