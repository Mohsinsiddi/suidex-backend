import { logger } from '../utils/logger';

export class PriceOracle {
  async getTokenPriceUSD(params: {
    tokenAddress: string;
    timestamp: Date;
  }): Promise<number> {
    logger.debug({ ...params }, 'Price oracle query (not implemented)');
    return 0;
  }

  calculatePriceFromReserves(params: {
    reserve0: string;
    reserve1: string;
    token0Decimals: number;
    token1Decimals: number;
  }): number {
    const r0 = BigInt(params.reserve0);
    const r1 = BigInt(params.reserve1);
    if (r0 === 0n) return 0;
    const price = Number(r1) / Number(r0);
    return price;
  }
}
