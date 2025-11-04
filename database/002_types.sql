-- ============================================================================
-- Custom Types
-- ============================================================================

CREATE TYPE pool_type AS ENUM ('lp', 'single');
CREATE TYPE lock_period AS ENUM ('week', 'three_month', 'year', 'three_year');
CREATE TYPE tx_status AS ENUM ('success', 'failed', 'pending');
CREATE TYPE position_status AS ENUM ('active', 'closed');