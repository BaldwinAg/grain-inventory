-- ============================================================================
-- BREAKEVEN CALCULATOR PHASE 2 ENHANCEMENTS
-- Family Living, Debt Service, and Field-Level Expenses
-- Run this in Supabase SQL Editor
-- ============================================================================

-- ============================================================================
-- SPECIAL CATEGORY FLAGS
-- Identify Family Living and Debt Service for toggle/filtering
-- ============================================================================

-- Add special category flags
ALTER TABLE be_overhead_categories
ADD COLUMN IF NOT EXISTS is_family_living BOOLEAN DEFAULT false,
ADD COLUMN IF NOT EXISTS is_debt_service BOOLEAN DEFAULT false;

-- Add comments for documentation
COMMENT ON COLUMN be_overhead_categories.is_family_living IS 'When true, this category can be toggled off in reports to see profit before personal draw';
COMMENT ON COLUMN be_overhead_categories.is_debt_service IS 'When true, this category tracks loan/debt payments spread across all acres';

-- ============================================================================
-- CREATE BASE OVERHEAD CATEGORIES (if missing)
-- These should have been created by farm_management_suite.sql
-- ============================================================================

-- Insert base categories if they don't exist
INSERT INTO be_overhead_categories (name, sort_order, active)
SELECT 'Equipment', 1, true WHERE NOT EXISTS (SELECT 1 FROM be_overhead_categories WHERE name = 'Equipment');

INSERT INTO be_overhead_categories (name, sort_order, active)
SELECT 'Labor', 2, true WHERE NOT EXISTS (SELECT 1 FROM be_overhead_categories WHERE name = 'Labor');

INSERT INTO be_overhead_categories (name, sort_order, active)
SELECT 'Fixed Costs', 3, true WHERE NOT EXISTS (SELECT 1 FROM be_overhead_categories WHERE name = 'Fixed Costs');

INSERT INTO be_overhead_categories (name, sort_order, active)
SELECT 'Insurance', 4, true WHERE NOT EXISTS (SELECT 1 FROM be_overhead_categories WHERE name = 'Insurance');

INSERT INTO be_overhead_categories (name, sort_order, active)
SELECT 'Miscellaneous', 5, true WHERE NOT EXISTS (SELECT 1 FROM be_overhead_categories WHERE name = 'Miscellaneous');

-- ============================================================================
-- CREATE SPECIAL CATEGORIES (Family Living & Debt Service)
-- ============================================================================

-- Insert Family Living category
INSERT INTO be_overhead_categories (name, sort_order, is_family_living, active)
SELECT 'Family Living', 90, true, true
WHERE NOT EXISTS (
  SELECT 1 FROM be_overhead_categories WHERE name = 'Family Living'
);

-- Mark existing Family Living category if it exists
UPDATE be_overhead_categories
SET is_family_living = true
WHERE name = 'Family Living';

-- Insert Debt Service category
INSERT INTO be_overhead_categories (name, sort_order, is_debt_service, active)
SELECT 'Debt Service', 91, true, true
WHERE NOT EXISTS (
  SELECT 1 FROM be_overhead_categories WHERE name = 'Debt Service'
);

-- Mark existing Debt Service category if it exists
UPDATE be_overhead_categories
SET is_debt_service = true
WHERE name = 'Debt Service';

-- ============================================================================
-- FIELD-LEVEL EXPENSES
-- Allow overhead expenses to be allocated to specific fields
-- ============================================================================

-- Add field_id column for field-specific expense allocation
ALTER TABLE be_overhead_expenses
ADD COLUMN IF NOT EXISTS field_id UUID REFERENCES fields(id);

-- Add SPECIFIC_FIELD as valid allocation_type option
-- (No ALTER needed - the column is VARCHAR so any value works)
COMMENT ON COLUMN be_overhead_expenses.field_id IS 'When allocation_type=SPECIFIC_FIELD, links to the specific field';

-- Add index for field-specific expense lookups
CREATE INDEX IF NOT EXISTS idx_be_overhead_expenses_field ON be_overhead_expenses(field_id);

-- ============================================================================
-- UPDATE EXISTING DATA
-- Ensure new columns have proper defaults
-- ============================================================================

-- Ensure all categories have the new flags set (false by default except for special categories)
UPDATE be_overhead_categories
SET is_family_living = COALESCE(is_family_living, false),
    is_debt_service = COALESCE(is_debt_service, false)
WHERE is_family_living IS NULL OR is_debt_service IS NULL;

-- ============================================================================
-- VERIFICATION QUERIES
-- Run separately to verify migration success
-- ============================================================================

-- Verify special category flags
-- SELECT id, name, is_family_living, is_debt_service FROM be_overhead_categories WHERE deleted_at IS NULL ORDER BY sort_order;

-- Verify field_id column exists
-- SELECT column_name, data_type FROM information_schema.columns WHERE table_name = 'be_overhead_expenses' AND column_name = 'field_id';

-- Check for Family Living and Debt Service categories
-- SELECT name, is_family_living, is_debt_service FROM be_overhead_categories WHERE (is_family_living = true OR is_debt_service = true) AND deleted_at IS NULL;

