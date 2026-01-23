-- Migration: Phase 2 - Audit Trail and Soft Delete
-- Run this in Supabase SQL Editor
-- Adds audit logging and soft delete support for data integrity

-- ============================================================================
-- PART 1: AUDIT LOG TABLE
-- ============================================================================

CREATE TABLE IF NOT EXISTS audit_log (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id),
  user_email TEXT,
  table_name TEXT NOT NULL,
  record_id UUID NOT NULL,
  action TEXT NOT NULL CHECK (action IN ('INSERT', 'UPDATE', 'DELETE', 'RESTORE')),
  old_values JSONB,
  new_values JSONB,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Index for fast lookups by table and record
CREATE INDEX idx_audit_log_table_record ON audit_log(table_name, record_id);
CREATE INDEX idx_audit_log_created_at ON audit_log(created_at DESC);
CREATE INDEX idx_audit_log_user_id ON audit_log(user_id);

-- Enable RLS on audit_log
ALTER TABLE audit_log ENABLE ROW LEVEL SECURITY;

-- Authenticated users can view audit log
CREATE POLICY "Authenticated users can read audit_log"
  ON audit_log FOR SELECT
  TO authenticated
  USING (true);

-- Authenticated users can insert audit entries
CREATE POLICY "Authenticated users can insert audit_log"
  ON audit_log FOR INSERT
  TO authenticated
  WITH CHECK (true);

-- ============================================================================
-- PART 2: SOFT DELETE COLUMNS
-- Add deleted_at to grain-specific tables
-- ============================================================================

-- Contracts (main table)
ALTER TABLE contracts ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMPTZ DEFAULT NULL;
CREATE INDEX IF NOT EXISTS idx_contracts_deleted_at ON contracts(deleted_at);

-- Buyers
ALTER TABLE buyers ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMPTZ DEFAULT NULL;
CREATE INDEX IF NOT EXISTS idx_buyers_deleted_at ON buyers(deleted_at);

-- Commodities
ALTER TABLE commodities ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMPTZ DEFAULT NULL;
CREATE INDEX IF NOT EXISTS idx_commodities_deleted_at ON commodities(deleted_at);

-- Field Crop Years
ALTER TABLE field_crop_years ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMPTZ DEFAULT NULL;
CREATE INDEX IF NOT EXISTS idx_field_crop_years_deleted_at ON field_crop_years(deleted_at);

-- Grain Field Settings
ALTER TABLE grain_field_settings ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMPTZ DEFAULT NULL;
CREATE INDEX IF NOT EXISTS idx_grain_field_settings_deleted_at ON grain_field_settings(deleted_at);

-- Insurance Settings
ALTER TABLE insurance_settings ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMPTZ DEFAULT NULL;
CREATE INDEX IF NOT EXISTS idx_insurance_settings_deleted_at ON insurance_settings(deleted_at);

-- Location Basis
ALTER TABLE location_basis ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMPTZ DEFAULT NULL;
CREATE INDEX IF NOT EXISTS idx_location_basis_deleted_at ON location_basis(deleted_at);

-- Market Prices
ALTER TABLE market_prices ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMPTZ DEFAULT NULL;
CREATE INDEX IF NOT EXISTS idx_market_prices_deleted_at ON market_prices(deleted_at);

-- ============================================================================
-- PART 3: HELPER VIEW FOR DELETED ITEMS (TRASH)
-- ============================================================================

-- View to see all deleted contracts
CREATE OR REPLACE VIEW deleted_contracts AS
SELECT
  c.*,
  b.name as buyer_name,
  cm.name as commodity_name
FROM contracts c
LEFT JOIN buyers b ON c.buyer_id = b.id
LEFT JOIN commodities cm ON c.commodity_id = cm.id
WHERE c.deleted_at IS NOT NULL
ORDER BY c.deleted_at DESC;

-- ============================================================================
-- NOTES FOR APPLICATION CODE
-- ============================================================================
--
-- 1. All SELECT queries should add: WHERE deleted_at IS NULL
--
-- 2. To "delete" a record, UPDATE with: deleted_at = now()
--
-- 3. To restore a record: deleted_at = NULL
--
-- 4. Log audit entries on every INSERT, UPDATE, DELETE:
--    INSERT INTO audit_log (user_id, user_email, table_name, record_id, action, old_values, new_values)
--    VALUES (auth.uid(), user_email, 'contracts', record_id, 'UPDATE', old_json, new_json)
--
-- 5. Consider adding a scheduled job to purge records older than 30 days
--    (can be done via Supabase Edge Function or external cron)
