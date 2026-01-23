-- Migration: Phase 4 - Contract Enhancements
-- Run this in Supabase SQL Editor
-- Adds support for:
--   - SPOT vs FORWARD cash sales
--   - Futures/Options entry/exit tracking
--   - Realized P&L calculation
--   - Discounts, checkoff, storage for spot sales

-- ============================================================================
-- PART 1: ADD NEW CONTRACT TYPES
-- ============================================================================

-- Update contract_type check constraint to include SPOT and FORWARD
-- First drop existing constraint if any, then add new one
ALTER TABLE contracts DROP CONSTRAINT IF EXISTS contracts_contract_type_check;
ALTER TABLE contracts ADD CONSTRAINT contracts_contract_type_check
  CHECK (contract_type IN ('CASH', 'SPOT', 'FORWARD', 'FUTURES', 'OPTIONS', 'HTA', 'BASIS'));

-- ============================================================================
-- PART 2: ADD EXIT/CLOSE POSITION FIELDS
-- ============================================================================

-- For futures - exit price when closing position
ALTER TABLE contracts ADD COLUMN IF NOT EXISTS exit_date DATE DEFAULT NULL;
ALTER TABLE contracts ADD COLUMN IF NOT EXISTS exit_price DECIMAL(10,4) DEFAULT NULL;

-- For options - exit premium when closing position
ALTER TABLE contracts ADD COLUMN IF NOT EXISTS exit_premium DECIMAL(10,4) DEFAULT NULL;

-- Realized P&L when position is closed
ALTER TABLE contracts ADD COLUMN IF NOT EXISTS realized_pnl DECIMAL(12,2) DEFAULT NULL;

-- Link closing trade to opening trade
ALTER TABLE contracts ADD COLUMN IF NOT EXISTS linked_exit_id UUID DEFAULT NULL REFERENCES contracts(id) ON DELETE SET NULL;

-- Index for exit lookups
CREATE INDEX IF NOT EXISTS idx_contracts_linked_exit_id ON contracts(linked_exit_id);

-- ============================================================================
-- PART 3: ADD CASH SALE DETAIL FIELDS
-- ============================================================================

-- Futures reference price (the futures component of a cash sale)
ALTER TABLE contracts ADD COLUMN IF NOT EXISTS futures_reference DECIMAL(10,4) DEFAULT NULL;

-- Discounts (moisture, test weight, damage, FM combined)
ALTER TABLE contracts ADD COLUMN IF NOT EXISTS discounts DECIMAL(10,4) DEFAULT NULL;

-- Checkoff fees
ALTER TABLE contracts ADD COLUMN IF NOT EXISTS checkoff DECIMAL(10,4) DEFAULT NULL;

-- Storage charges
ALTER TABLE contracts ADD COLUMN IF NOT EXISTS storage_charges DECIMAL(10,4) DEFAULT NULL;

-- ============================================================================
-- PART 4: UPDATE STATUS CHECK CONSTRAINT
-- ============================================================================

-- Add CLOSED and EXPIRED status options
ALTER TABLE contracts DROP CONSTRAINT IF EXISTS contracts_status_check;
ALTER TABLE contracts ADD CONSTRAINT contracts_status_check
  CHECK (status IN ('OPEN', 'CLOSED', 'EXPIRED', 'FILLED', 'CANCELLED'));

-- ============================================================================
-- PART 5: MIGRATE EXISTING CASH TO FORWARD
-- ============================================================================

-- Existing CASH contracts are likely forward contracts (no discounts)
-- Migrate them to FORWARD type
UPDATE contracts
SET contract_type = 'FORWARD',
    futures_reference = cash_price,  -- Assume cash_price was the net, we'll need to separate later
    basis = COALESCE(basis, 0)
WHERE contract_type = 'CASH';

-- ============================================================================
-- NOTES FOR APPLICATION
-- ============================================================================
--
-- FORWARD sale net price = futures_reference + basis
-- SPOT sale net price = futures_reference + basis - discounts - checkoff - storage_charges
--
-- When closing a FUTURES position:
--   1. Create new contract with opposite direction (or update exit fields)
--   2. Set exit_date, exit_price
--   3. Calculate realized_pnl = (exit_price - futures_price) * bushels * direction
--      (direction: -1 for short/sold, +1 for long/bought)
--   4. Set status = 'CLOSED'
--
-- When closing an OPTIONS position:
--   1. Set exit_date, exit_premium
--   2. Calculate realized_pnl based on premium difference
--   3. Set status = 'CLOSED'
--
-- When option expires:
--   1. Set status = 'EXPIRED'
--   2. realized_pnl = -premium (for long) or +premium (for short)
--
-- Blended average calculation should include:
--   - Cash/Forward/Spot sale prices
--   - Realized P&L from closed futures/options positions
