/**
 * Type conversion utilities
 */

/**
 * Convert u256 string to BigInt
 */
export function u256ToBigInt(value: string): bigint {
  return BigInt(value);
}

/**
 * Convert u64 string to number (safe for JavaScript)
 */
export function u64ToNumber(value: string): number {
  const num = BigInt(value);
  if (num > Number.MAX_SAFE_INTEGER) {
    throw new Error(`u64 value ${value} exceeds JavaScript safe integer range`);
  }
  return Number(num);
}

/**
 * Convert BigInt to u256 string
 */
export function bigIntToU256(value: bigint): string {
  return value.toString();
}

/**
 * Convert number to u64 string
 */
export function numberToU64(value: number): string {
  if (!Number.isSafeInteger(value)) {
    throw new Error(`Number ${value} is not a safe integer`);
  }
  return value.toString();
}

/**
 * Convert milliseconds timestamp to seconds
 */
export function msToSeconds(ms: string | number): number {
  const milliseconds = typeof ms === 'string' ? parseInt(ms) : ms;
  return Math.floor(milliseconds / 1000);
}

/**
 * Convert seconds timestamp to milliseconds
 */
export function secondsToMs(seconds: string | number): number {
  const secs = typeof seconds === 'string' ? parseInt(seconds) : seconds;
  return secs * 1000;
}

/**
 * Convert basis points to decimal
 */
export function bpsToDecimal(bps: number): number {
  return bps / 10000;
}

/**
 * Convert decimal to basis points
 */
export function decimalToBps(decimal: number): number {
  return Math.round(decimal * 10000);
}

/**
 * Convert lock period seconds to enum
 */
export function secondsToLockPeriod(seconds: number | string): 'week' | 'three_month' | 'year' | 'three_year' {
  const secs = typeof seconds === 'string' ? parseInt(seconds) : seconds;
  const WEEK = 7 * 24 * 60 * 60;
  const THREE_MONTHS = 90 * 24 * 60 * 60;
  const YEAR = 365 * 24 * 60 * 60;
  
  if (secs <= WEEK) return 'week';
  if (secs <= THREE_MONTHS) return 'three_month';
  if (secs <= YEAR) return 'year';
  return 'three_year';
}

/**
 * Convert lock period enum to seconds
 */
export function lockPeriodToSeconds(period: 'week' | 'three_month' | 'year' | 'three_year'): number {
  const WEEK = 7 * 24 * 60 * 60;
  const THREE_MONTHS = 90 * 24 * 60 * 60;
  const YEAR = 365 * 24 * 60 * 60;
  const THREE_YEARS = 3 * 365 * 24 * 60 * 60;
  
  switch (period) {
    case 'week':
      return WEEK;
    case 'three_month':
      return THREE_MONTHS;
    case 'year':
      return YEAR;
    case 'three_year':
      return THREE_YEARS;
  }
}
