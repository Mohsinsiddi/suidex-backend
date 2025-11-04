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
