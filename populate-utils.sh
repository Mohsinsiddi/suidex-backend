#!/bin/bash

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}📦 Populating Shared Utils Folder...${NC}\n"

# Create utils directory if it doesn't exist
mkdir -p packages/shared/src/utils

# ============================================================================
# utils/validators.ts - Type Guards and Validators
# ============================================================================

echo -e "${YELLOW}Creating utils/validators.ts...${NC}"

cat > packages/shared/src/utils/validators.ts << 'EOF'
/**
 * Type guards and validators for shared types
 */

/**
 * Check if a value is a valid Sui address
 */
export function isValidSuiAddress(address: string): boolean {
  return /^0x[a-fA-F0-9]{64}$/.test(address) || /^0x[a-fA-F0-9]{1,64}$/.test(address);
}

/**
 * Check if a value is a valid transaction digest
 */
export function isValidTxDigest(digest: string): boolean {
  return /^[A-Za-z0-9+/]{43}=$/.test(digest) || /^[a-fA-F0-9]{64}$/.test(digest);
}

/**
 * Check if a string represents a valid numeric value
 */
export function isNumericString(value: string): boolean {
  return /^\d+$/.test(value);
}

/**
 * Validate TypeName format
 */
export function isValidTypeName(typeName: string): boolean {
  // Format: "0xPACKAGE::module::Type"
  return /^0x[a-fA-F0-9]+::\w+::\w+/.test(typeName);
}

/**
 * Check if a value is a valid u64 (within safe range)
 */
export function isValidU64(value: string): boolean {
  try {
    const num = BigInt(value);
    return num >= 0n && num <= 18446744073709551615n; // 2^64 - 1
  } catch {
    return false;
  }
}

/**
 * Check if a value is a valid u256
 */
export function isValidU256(value: string): boolean {
  try {
    const num = BigInt(value);
    const max = (1n << 256n) - 1n;
    return num >= 0n && num <= max;
  } catch {
    return false;
  }
}

/**
 * Validate epoch ID format
 */
export function isValidEpochId(epochId: string): boolean {
  return isNumericString(epochId);
}

/**
 * Validate lock period
 */
export function isValidLockPeriod(period: string): boolean {
  const validPeriods = ['week', 'three_month', 'year', 'three_year'];
  return validPeriods.includes(period);
}
EOF

# ============================================================================
# utils/formatters.ts - Formatting Utilities
# ============================================================================

echo -e "${YELLOW}Creating utils/formatters.ts...${NC}"

cat > packages/shared/src/utils/formatters.ts << 'EOF'
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
EOF

# ============================================================================
# utils/conversions.ts - Type Conversions
# ============================================================================

echo -e "${YELLOW}Creating utils/conversions.ts...${NC}"

cat > packages/shared/src/utils/conversions.ts << 'EOF'
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
EOF

# ============================================================================
# utils/errors.ts - Error Handling
# ============================================================================

echo -e "${YELLOW}Creating utils/errors.ts...${NC}"

cat > packages/shared/src/utils/errors.ts << 'EOF'
/**
 * Custom error classes for better error handling
 */

/**
 * Base error class for application errors
 */
export class AppError extends Error {
  constructor(
    message: string,
    public code: string,
    public statusCode: number = 500
  ) {
    super(message);
    this.name = 'AppError';
  }
}

/**
 * Validation error
 */
export class ValidationError extends AppError {
  constructor(message: string, public field?: string) {
    super(message, 'VALIDATION_ERROR', 400);
    this.name = 'ValidationError';
  }
}

/**
 * Not found error
 */
export class NotFoundError extends AppError {
  constructor(resource: string) {
    super(`${resource} not found`, 'NOT_FOUND', 404);
    this.name = 'NotFoundError';
  }
}

/**
 * Database error
 */
export class DatabaseError extends AppError {
  constructor(message: string, public originalError?: Error) {
    super(message, 'DATABASE_ERROR', 500);
    this.name = 'DatabaseError';
  }
}

/**
 * Blockchain error
 */
export class BlockchainError extends AppError {
  constructor(message: string, public originalError?: Error) {
    super(message, 'BLOCKCHAIN_ERROR', 500);
    this.name = 'BlockchainError';
  }
}

/**
 * Parse error
 */
export class ParseError extends AppError {
  constructor(message: string, public data?: any) {
    super(message, 'PARSE_ERROR', 500);
    this.name = 'ParseError';
  }
}

/**
 * Rate limit error
 */
export class RateLimitError extends AppError {
  constructor(message = 'Rate limit exceeded') {
    super(message, 'RATE_LIMIT_EXCEEDED', 429);
    this.name = 'RateLimitError';
  }
}

/**
 * Authentication error
 */
export class AuthenticationError extends AppError {
  constructor(message = 'Authentication failed') {
    super(message, 'AUTHENTICATION_ERROR', 401);
    this.name = 'AuthenticationError';
  }
}

/**
 * Authorization error
 */
export class AuthorizationError extends AppError {
  constructor(message = 'Insufficient permissions') {
    super(message, 'AUTHORIZATION_ERROR', 403);
    this.name = 'AuthorizationError';
  }
}

/**
 * Check if error is an AppError
 */
export function isAppError(error: any): error is AppError {
  return error instanceof AppError;
}

/**
 * Format error for API response
 */
export function formatError(error: Error): {
  error: string;
  code: string;
  statusCode: number;
  details?: any;
} {
  if (isAppError(error)) {
    return {
      error: error.message,
      code: error.code,
      statusCode: error.statusCode,
    };
  }
  
  return {
    error: error.message || 'Internal server error',
    code: 'INTERNAL_ERROR',
    statusCode: 500,
  };
}
EOF

# ============================================================================
# utils/index.ts - Export all utilities
# ============================================================================

echo -e "${YELLOW}Creating utils/index.ts...${NC}"

cat > packages/shared/src/utils/index.ts << 'EOF'
/**
 * Shared utility functions
 * Used across indexer and API packages
 */

export * from './validators';
export * from './formatters';
export * from './conversions';
export * from './errors';
EOF

# ============================================================================
# Update shared/src/index.ts to include utils
# ============================================================================

echo -e "${YELLOW}Updating shared/src/index.ts...${NC}"

cat > packages/shared/src/index.ts << 'EOF'
/**
 * Shared package exports
 * Types, constants, and utilities used across indexer and API
 */

// Event types
export * from './types/events';

// Database types
export * from './types/database';

// Constants and helpers
export * from './constants';

// Utilities
export * from './utils';
EOF

# ============================================================================
# DONE
# ============================================================================

echo -e "${GREEN}✅ Shared utils folder populated!${NC}\n"

echo -e "${YELLOW}📋 Files created:${NC}"
echo "  ✓ utils/validators.ts - Type guards and validators"
echo "  ✓ utils/formatters.ts - Display formatting functions"
echo "  ✓ utils/conversions.ts - Type conversion utilities"
echo "  ✓ utils/errors.ts - Custom error classes"
echo "  ✓ utils/index.ts - Exports"
echo "  ✓ Updated src/index.ts - Added utils exports"

echo -e "\n${GREEN}🎉 Ready to use shared utilities!${NC}"
echo -e "${YELLOW}Import example: import { formatTokenAmount, isValidSuiAddress } from '@shared/utils';${NC}"