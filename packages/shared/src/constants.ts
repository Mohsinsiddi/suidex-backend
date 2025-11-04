// Constants will go here
export const CONTRACTS = {
  PAIR_PACKAGE_ID: process.env.PAIR_PACKAGE_ID || '',
  FARM_PACKAGE_ID: process.env.FARM_PACKAGE_ID || '',
  LOCKER_PACKAGE_ID: process.env.LOCKER_PACKAGE_ID || '',
} as const;

export const DECIMALS = {
  SUI: 9,
  VICTORY: 6,
  DEFAULT: 6,
} as const;
