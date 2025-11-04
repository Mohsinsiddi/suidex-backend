// src/services/emission-config.ts
import { SuiClient } from '@mysten/sui.js/client';
import { logger } from '../utils/logger';
import { config } from '../config'; // Import config

const SECONDS_PER_WEEK = 604800;

class EmissionConfigService {
  private emissionStartTimestamp: number | null = null;
  private suiClient: SuiClient;

  constructor() {
    this.suiClient = new SuiClient({ 
      url: config.SUI_RPC_URL 
    });
  }

  async initialize(): Promise<void> {
    if (this.emissionStartTimestamp) return;

    try {
      const result = await this.suiClient.getObject({
        id: config.EMISSION_CONTROLLER_ADDRESS, // Use from config
        options: { showContent: true }
      });

      const fields = (result.data?.content as any)?.fields;
      this.emissionStartTimestamp = parseInt(fields.emission_start_timestamp);

      logger.info({ 
        emissionStart: this.emissionStartTimestamp,
        date: new Date(this.emissionStartTimestamp * 1000).toISOString()
      }, 'Emission config initialized');
    } catch (error) {
      logger.error({ error }, 'Failed to fetch emission start time');
      throw new Error('Cannot start indexer without emission config');
    }
  }

  getEmissionStartTime(): number {
    if (!this.emissionStartTimestamp) {
      throw new Error('Emission config not initialized');
    }
    return this.emissionStartTimestamp;
  }

  calculateWeekTimestamps(weekNumber: number) {
    const start = this.getEmissionStartTime();
    
    return {
      week_start: new Date((start + (weekNumber - 1) * SECONDS_PER_WEEK) * 1000),
      week_end: new Date((start + weekNumber * SECONDS_PER_WEEK) * 1000),
    };
  }

  getCurrentWeek(): number {
    const start = this.getEmissionStartTime();
    const now = Math.floor(Date.now() / 1000);
    const elapsed = now - start;
    return Math.floor(elapsed / SECONDS_PER_WEEK) + 1;
  }
}

export const emissionConfig = new EmissionConfigService();