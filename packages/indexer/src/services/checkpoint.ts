import { getCheckpoint, updateCheckpoint, getSafeCheckpoint } from '../db/queries';
import { logger } from '../utils/logger';

type ContractType = 'pair' | 'farm' | 'locker';

export class CheckpointManager {
  private checkpoints: Map<ContractType, string> = new Map();

  async loadCheckpoints(): Promise<void> {
    const contracts: ContractType[] = ['pair', 'farm', 'locker'];
    
    for (const contractType of contracts) {
      const checkpoint = await getCheckpoint(contractType);
      if (checkpoint) {
        this.checkpoints.set(contractType, checkpoint.checkpoint);
        logger.info({ contractType, checkpoint: checkpoint.checkpoint }, 'Loaded checkpoint');
      } else {
        this.checkpoints.set(contractType, '0');
        logger.info({ contractType }, 'No checkpoint found, starting from 0');
      }
    }
  }

  getCheckpoint(contractType: ContractType): string {
    return this.checkpoints.get(contractType) || '0';
  }

  async getSafeResumeCheckpoint(): Promise<string> {
    const safe = await getSafeCheckpoint();
    return safe || '0';
  }

  async saveCheckpoint(params: {
    contractType: ContractType;
    checkpoint: string;
    txDigest: string;
  }): Promise<void> {
    try {
      await updateCheckpoint({
        contract_type: params.contractType,
        checkpoint: params.checkpoint,
        last_tx_digest: params.txDigest,
      });
      this.checkpoints.set(params.contractType, params.checkpoint);
      
      logger.debug({
        contractType: params.contractType,
        checkpoint: params.checkpoint,
      }, 'Checkpoint saved');
    } catch (error) {
      logger.error({ error, params }, 'Failed to save checkpoint');
      throw error;
    }
  }

  getAllCheckpoints(): Record<string, string> {
    return {
      pair: this.checkpoints.get('pair') || '0',
      farm: this.checkpoints.get('farm') || '0',
      locker: this.checkpoints.get('locker') || '0',
    };
  }
}
