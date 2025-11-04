/**
 * Global constants and configuration
 * Contract addresses, decimals, and event type mappings
 */

// ============================================================================
// CONTRACT ADDRESSES (Update these with your deployed contracts!)
// ============================================================================

export const CONTRACTS = {
  PAIR_PACKAGE_ID: process.env.PAIR_PACKAGE_ID || '0x50c2216a078d3bdf5081fe436df9f42dfdbe538ebd9c935913ce2436362cff90',
  FARM_PACKAGE_ID: process.env.FARM_PACKAGE_ID || '0x3f4ae88398b5a250a2ce44484a9420c1645c189a949e8b89e57f6e03bfc235ce',
  LOCKER_PACKAGE_ID: process.env.LOCKER_PACKAGE_ID || '0xac4c650543b6360f56be83f973b458037b77fcd3c7fbe23bfc422c830a2d91e9',
} as const;

// ============================================================================
// TOKEN DECIMALS
// ============================================================================

export const DECIMALS = {
  SUI: 9,
  VICTORY: 6,
  USDC: 6,
  USDT: 6,
  DEFAULT: 6,
} as const;

// ============================================================================
// EVENT TYPE STRINGS (For Sui event filtering)
// ============================================================================

export const EVENT_TYPES = {
  // Pair events
  SWAP: (pkg: string) => `${pkg}::pair::Swap`,
  LP_MINT: (pkg: string) => `${pkg}::pair::LPMint`,
  LP_BURN: (pkg: string) => `${pkg}::pair::LPBurn`,
  SYNC: (pkg: string) => `${pkg}::pair::Sync`,
  PAIR_CREATED: (pkg: string) => `${pkg}::factory::PairCreated`,
  
  // Farm events
  STAKED: (pkg: string) => `${pkg}::farm::Staked`,
  UNSTAKED: (pkg: string) => `${pkg}::farm::Unstaked`,
  REWARD_CLAIMED: (pkg: string) => `${pkg}::farm::RewardClaimed`,
  POOL_CREATED: (pkg: string) => `${pkg}::farm::PoolCreated`,
  
  // Locker events
  TOKENS_LOCKED: (pkg: string) => `${pkg}::victory_token_locker::TokensLocked`,
  TOKENS_UNLOCKED: (pkg: string) => `${pkg}::victory_token_locker::TokensUnlocked`,
  VICTORY_REWARDS_CLAIMED: (pkg: string) => `${pkg}::victory_token_locker::VictoryRewardsClaimed`,
  POOL_SUI_CLAIMED: (pkg: string) => `${pkg}::victory_token_locker::PoolSUIClaimed`,
  EPOCH_CREATED: (pkg: string) => `${pkg}::victory_token_locker::EpochCreated`,
  WEEKLY_REVENUE_ADDED: (pkg: string) => `${pkg}::victory_token_locker::WeeklyRevenueAdded`,
} as const;

// ============================================================================
// KNOWN TOKEN ADDRESSES (Add as you discover them)
// ============================================================================

export const KNOWN_TOKENS: Record<string, { symbol: string; decimals: number }> = {
  '0x2::sui::SUI': { symbol: 'SUI', decimals: 9 },
  // Add Victory token address when known
  // Add other tokens as discovered
};

// ============================================================================
// DATABASE CONFIGURATION
// ============================================================================

export const DB_CONFIG = {
  BATCH_SIZE: 100, // Insert in batches of 100 events
  MAX_RETRIES: 3,
  RETRY_DELAY_MS: 1000,
} as const;

// ============================================================================
// INDEXER CONFIGURATION
// ============================================================================

export const INDEXER_CONFIG = {
  CHECKPOINT_INTERVAL_MS: 5000, // Save checkpoint every 5 seconds
  EVENT_BATCH_SIZE: 50, // Process 50 events at a time
  MAX_EVENTS_PER_QUERY: 1000,
} as const;

// ============================================================================
// HELPER FUNCTIONS
// ============================================================================

/**
 * Extract event name from full type string
 * Example: "0xabc::pair::Swap<0x2::sui::SUI, 0x123::token::USDC>" -> "Swap"
 */
export function extractEventName(fullType: string): string {
  const match = fullType.match(/::(\w+)(?:<|$)/);
  return match ? match[1] : '';
}

/**
 * Extract package ID from event type
 * Example: "0xabc::pair::Swap" -> "0xabc"
 */
export function extractPackageId(fullType: string): string {
  const match = fullType.match(/^(0x[a-fA-F0-9]+)::/);
  return match ? match[1] : '';
}

/**
 * Determine contract type from package ID
 */
export function getContractType(packageId: string): 'pair' | 'farm' | 'locker' | null {
  if (packageId === CONTRACTS.PAIR_PACKAGE_ID) return 'pair';
  if (packageId === CONTRACTS.FARM_PACKAGE_ID) return 'farm';
  if (packageId === CONTRACTS.LOCKER_PACKAGE_ID) return 'locker';
  return null;
}
