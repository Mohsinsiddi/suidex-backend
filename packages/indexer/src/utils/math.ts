export function u256ToBigInt(value: string): bigint {
  return BigInt(value);
}

export function u64ToNumber(value: string): number {
  return parseInt(value);
}

export function extractTokenAddress(typeName: string | { name: string }): string {
  if (typeof typeName === 'string') return typeName;
  return typeName.name;
}

export function calculatePercentage(part: bigint, total: bigint, decimals = 2): number {
  if (total === 0n) return 0;
  const percentage = (Number(part) / Number(total)) * 100;
  return Math.round(percentage * Math.pow(10, decimals)) / Math.pow(10, decimals);
}

export function formatTokenAmount(amount: string, decimals: number): string {
  const value = BigInt(amount);
  const divisor = BigInt(10 ** decimals);
  const whole = value / divisor;
  const fraction = value % divisor;
  return `${whole}.${fraction.toString().padStart(decimals, '0')}`;
}

export function calculateAPR(params: {
  rewardsPerSecond: bigint;
  totalStaked: bigint;
  rewardTokenPrice: number;
  stakedTokenPrice: number;
}): number {
  if (params.totalStaked === 0n) return 0;
  const secondsPerYear = 365 * 24 * 60 * 60;
  const yearlyRewards = Number(params.rewardsPerSecond) * secondsPerYear;
  const yearlyRewardsUSD = yearlyRewards * params.rewardTokenPrice;
  const totalStakedUSD = Number(params.totalStaked) * params.stakedTokenPrice;
  if (totalStakedUSD === 0) return 0;
  return (yearlyRewardsUSD / totalStakedUSD) * 100;
}
