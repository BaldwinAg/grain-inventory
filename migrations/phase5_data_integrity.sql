-- Phase 5: Data Integrity & Feature Enhancements
-- Run in Supabase SQL Editor

-- ============================================================================
-- 1. Quality fields on grain_inventory
-- ============================================================================
ALTER TABLE grain_inventory ADD COLUMN IF NOT EXISTS moisture DECIMAL(5,2) DEFAULT NULL;
ALTER TABLE grain_inventory ADD COLUMN IF NOT EXISTS test_weight DECIMAL(5,2) DEFAULT NULL;
ALTER TABLE grain_inventory ADD COLUMN IF NOT EXISTS grade VARCHAR(20) DEFAULT NULL;
ALTER TABLE grain_inventory ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMPTZ DEFAULT NULL;

-- ============================================================================
-- 2. Quality fields on inventory_transactions
-- ============================================================================
ALTER TABLE inventory_transactions ADD COLUMN IF NOT EXISTS moisture DECIMAL(5,2) DEFAULT NULL;
ALTER TABLE inventory_transactions ADD COLUMN IF NOT EXISTS test_weight DECIMAL(5,2) DEFAULT NULL;
ALTER TABLE inventory_transactions ADD COLUMN IF NOT EXISTS grade VARCHAR(20) DEFAULT NULL;

-- ============================================================================
-- 3. Add deleted_at to grain_locations if missing
-- ============================================================================
ALTER TABLE grain_locations ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMPTZ DEFAULT NULL;

-- ============================================================================
-- 4. Delivery method and filled status on contracts
-- ============================================================================
ALTER TABLE contracts ADD COLUMN IF NOT EXISTS delivery_method VARCHAR(20) DEFAULT 'DELIVERY';
ALTER TABLE contracts ADD COLUMN IF NOT EXISTS filled_status VARCHAR(20) DEFAULT 'NOT_FILLED';

-- ============================================================================
-- 5. Soft delete indexes
-- ============================================================================
CREATE INDEX IF NOT EXISTS idx_grain_inventory_deleted ON grain_inventory(deleted_at);
CREATE INDEX IF NOT EXISTS idx_grain_locations_deleted ON grain_locations(deleted_at);
CREATE INDEX IF NOT EXISTS idx_commodities_deleted ON commodities(deleted_at);
CREATE INDEX IF NOT EXISTS idx_grain_field_settings_deleted ON grain_field_settings(deleted_at);
CREATE INDEX IF NOT EXISTS idx_location_basis_deleted ON location_basis(deleted_at);

-- ============================================================================
-- 6. Buyer-specific basis table (drop if exists to ensure clean state)
-- ============================================================================
DROP TABLE IF EXISTS buyer_basis CASCADE;

CREATE TABLE buyer_basis (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  buyer_id UUID NOT NULL REFERENCES buyers(id) ON DELETE CASCADE,
  commodity_id UUID NOT NULL REFERENCES commodities(id) ON DELETE CASCADE,
  crop_year INTEGER NOT NULL,
  basis DECIMAL(10,4) NOT NULL,
  futures_month VARCHAR(20) DEFAULT NULL,
  notes TEXT DEFAULT NULL,
  deleted_at TIMESTAMPTZ DEFAULT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(buyer_id, commodity_id, crop_year, futures_month)
);

CREATE INDEX idx_buyer_basis_lookup ON buyer_basis(buyer_id, commodity_id, crop_year);
CREATE INDEX idx_buyer_basis_deleted ON buyer_basis(deleted_at);

-- ============================================================================
-- 7. Enable RLS on buyer_basis
-- ============================================================================
ALTER TABLE buyer_basis ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Public read access for buyer_basis"
ON buyer_basis FOR SELECT TO public USING (true);

CREATE POLICY "Public write access for buyer_basis"
ON buyer_basis FOR ALL TO public USING (true) WITH CHECK (true);

-- ============================================================================
-- 8. Update trigger for buyer_basis
-- ============================================================================
CREATE OR REPLACE FUNCTION update_buyer_basis_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS buyer_basis_updated_at ON buyer_basis;
CREATE TRIGGER buyer_basis_updated_at
  BEFORE UPDATE ON buyer_basis
  FOR EACH ROW
  EXECUTE FUNCTION update_buyer_basis_updated_at();
