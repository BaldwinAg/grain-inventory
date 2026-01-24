-- ============================================================================
-- BREAKEVEN CALCULATOR PHASE 1: OVERHEAD ENHANCEMENTS
-- Run this in Supabase SQL Editor
-- ============================================================================

-- Add entry_mode and per_acre_amount to overhead expenses
ALTER TABLE be_overhead_expenses
ADD COLUMN IF NOT EXISTS entry_mode VARCHAR(10) DEFAULT 'TOTAL',
ADD COLUMN IF NOT EXISTS per_acre_amount DECIMAL(10,4) DEFAULT NULL;

-- Add comment for documentation
COMMENT ON COLUMN be_overhead_expenses.entry_mode IS 'TOTAL = fixed annual amount, PER_ACRE = amount per acre multiplied by allocated acres';
COMMENT ON COLUMN be_overhead_expenses.per_acre_amount IS 'When entry_mode=PER_ACRE, this stores the per-acre cost';

-- Fix duplicate overhead categories by keeping only the first of each name
-- First, identify duplicates and keep the one with lowest sort_order
WITH duplicates AS (
  SELECT id, name, sort_order,
         ROW_NUMBER() OVER (PARTITION BY name ORDER BY sort_order, created_at) as rn
  FROM be_overhead_categories
  WHERE deleted_at IS NULL AND active = true
)
UPDATE be_overhead_categories
SET deleted_at = NOW(), active = false
WHERE id IN (SELECT id FROM duplicates WHERE rn > 1);

-- Add unique constraint to prevent future duplicates (on name where not deleted)
-- Note: Supabase/Postgres doesn't support partial unique constraints easily,
-- so we'll handle deduplication in the application code as a backup

-- Update existing expenses to have entry_mode set if null
UPDATE be_overhead_expenses
SET entry_mode = 'TOTAL'
WHERE entry_mode IS NULL;

-- ============================================================================
-- VERIFICATION QUERIES (run separately to verify)
-- ============================================================================

-- Check for remaining duplicates
-- SELECT name, COUNT(*) FROM be_overhead_categories WHERE deleted_at IS NULL AND active = true GROUP BY name HAVING COUNT(*) > 1;

-- Verify columns added
-- SELECT column_name, data_type FROM information_schema.columns WHERE table_name = 'be_overhead_expenses' AND column_name IN ('entry_mode', 'per_acre_amount');
