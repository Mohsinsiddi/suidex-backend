import { SuiClient, type SuiEventFilter } from '@mysten/sui.js/client';
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
