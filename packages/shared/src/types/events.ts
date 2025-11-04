// Event type definitions will go here
export interface SwapEvent {
  sender: string;
  amount0_in: string;
  amount1_in: string;
  amount0_out: string;
  amount1_out: string;
}

export interface LPMintEvent {
  sender: string;
  lp_coin_id: string;
  token0_type: string;
  token1_type: string;
  amount0: string;
  amount1: string;
  liquidity: string;
  total_supply: string;
}

// More event types...
export interface ParsedSuiEvent<T> {
  id: {
    txDigest: string;
    eventSeq: string;
  };
  packageId: string;
  transactionModule: string;
  type: string;
  parsedJson: T;
  timestampMs: string;
}
