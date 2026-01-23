-- Migration: Add LONG/SHORT positions and contract linking for OPTIONS
-- Run this in Supabase SQL Editor

-- Add position_type: LONG (bought) or SHORT (sold)
ALTER TABLE contracts
ADD COLUMN IF NOT EXISTS position_type VARCHAR(10) DEFAULT NULL
CHECK (position_type IN ('LONG', 'SHORT') OR position_type IS NULL);

-- Add strategy_group_id for multi-leg strategy linking (e.g., 1 put + 2 calls in a collar)
ALTER TABLE contracts
ADD COLUMN IF NOT EXISTS strategy_group_id UUID DEFAULT NULL;

-- Add strategy_type for collar identification
ALTER TABLE contracts
ADD COLUMN IF NOT EXISTS strategy_type VARCHAR(20) DEFAULT NULL
CHECK (strategy_type IN ('COLLAR') OR strategy_type IS NULL);

-- Create index for strategy group lookups
CREATE INDEX IF NOT EXISTS idx_contracts_strategy_group_id ON contracts(strategy_group_id);

-- Backfill existing OPTIONS as LONG (since they were bought options)
UPDATE contracts
SET position_type = 'LONG'
WHERE contract_type = 'OPTIONS' AND position_type IS NULL;
