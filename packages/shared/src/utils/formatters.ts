/**
 * Formatting utilities for display and conversion
 */

/**
 * Shorten Sui address for display
 * Example: 0x1234...5678
 */
export function shortenAddress(address: string, startChars = 6, endChars = 4): string {
  if (address.length <= startChars + endChars) {
    return address;
  }
  return `${address.slice(0, startChars)}...${address.slice(-endChars)}`;
}

/**
 * Shorten transaction digest for display
 */
export function shortenTxDigest(digest: string, chars = 8): string {
  if (digest.length <= chars * 2) {
    return digest;
  }
  return `${digest.slice(0, chars)}...${digest.slice(-chars)}`;
}

/**
 * Format token amount with decimals
 */
export function formatTokenAmount(amount: string | bigint, decimals: number): string {
  const value = typeof amount === 'string' ? BigInt(amount) : amount;
  const divisor = BigInt(10 ** decimals);
  const whole = value / divisor;
  const fraction = value % divisor;
  
  const fractionStr = fraction.toString().padStart(decimals, '0');
  // Remove trailing zeros
  const trimmedFraction = fractionStr.replace(/0+$/, '');
  
  if (trimmedFraction === '') {
    return whole.toString();
  }
  
  return `${whole}.${trimmedFraction}`;
}

/**
 * Format token amount with commas for large numbers
 */
export function formatWithCommas(amount: string | number): string {
  const numStr = typeof amount === 'string' ? amount : amount.toString();
  const parts = numStr.split('.');
  parts[0] = parts[0].replace(/\B(?=(\d{3})+(?!\d))/g, ',');
  return parts.join('.');
}

/**
 * Format USD value
 */
export function formatUSD(value: number, decimals = 2): string {
  return `$${value.toLocaleString('en-US', {
    minimumFractionDigits: decimals,
    maximumFractionDigits: decimals,
  })}`;
}

/**
 * Format percentage
 */
export function formatPercentage(value: number, decimals = 2): string {
  return `${value.toFixed(decimals)}%`;
}

/**
 * Format large numbers with K, M, B suffixes
 */
export function formatCompactNumber(value: number): string {
  if (value >= 1_000_000_000) {
    return `${(value / 1_000_000_000).toFixed(2)}B`;
  }
  if (value >= 1_000_000) {
    return `${(value / 1_000_000).toFixed(2)}M`;
  }
  if (value >= 1_000) {
    return `${(value / 1_000).toFixed(2)}K`;
  }
  return value.toFixed(2);
}

/**
 * Format timestamp to ISO string
 */
export function formatTimestamp(timestamp: string | number): string {
  const ms = typeof timestamp === 'string' ? parseInt(timestamp) : timestamp;
  return new Date(ms).toISOString();
}

/**
 * Format duration in seconds to human readable
 */
export function formatDuration(seconds: number): string {
  const days = Math.floor(seconds / (24 * 60 * 60));
  const hours = Math.floor((seconds % (24 * 60 * 60)) / (60 * 60));
  const minutes = Math.floor((seconds % (60 * 60)) / 60);
  
  if (days > 0) {
    return `${days}d ${hours}h`;
  }
  if (hours > 0) {
    return `${hours}h ${minutes}m`;
  }
  return `${minutes}m`;
}

/**
 * Format APR/APY
 */
export function formatAPR(apr: number, isAPY = false): string {
  const label = isAPY ? 'APY' : 'APR';
  if (apr >= 1000) {
    return `${apr.toFixed(0)}% ${label}`;
  }
  if (apr >= 100) {
    return `${apr.toFixed(1)}% ${label}`;
  }
  return `${apr.toFixed(2)}% ${label}`;
}
