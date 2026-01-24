-- ============================================================================
-- Split with Landlord - Column Reference
-- ============================================================================
-- NOTE: The 'split' column ALREADY EXISTS in Spray-Suite:
--   - tank_mix_products.split = 'Y' or 'N' (set when building tank mix)
--   - application_products.split = 'Y' or 'N' (copied from tank mix or set manually)
--
-- This file documents the schema and provides helper views for Breakeven calculations.
-- ============================================================================

-- ============================================================================
-- VERIFICATION: Ensure split column exists on application_products
-- (This should already exist from Spray-Suite)
-- ============================================================================
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'application_products' AND column_name = 'split'
  ) THEN
    ALTER TABLE application_products ADD COLUMN split VARCHAR(1) DEFAULT 'N';
    COMMENT ON COLUMN application_products.split IS 'Y = split with landlord, N = 100% tenant';
  END IF;
END $$;

-- ============================================================================
-- Add split column to fert_application_products if not exists
-- (Fertilizer is always split, but column for consistency)
-- ============================================================================
ALTER TABLE fert_application_products
ADD COLUMN IF NOT EXISTS split_with_landlord BOOLEAN DEFAULT true;

COMMENT ON COLUMN fert_application_products.split_with_landlord IS
'Fertilizer is always split with landlord at grain share %. Default true.';

-- ============================================================================
-- View: Field cost context for breakeven calculations
-- Combines field info, landlord/tenant shares, and rent type
-- ============================================================================
CREATE OR REPLACE VIEW v_field_cost_context AS
SELECT
  f.id as field_id,
  f.name as field_name,
  f.tenant_share,
  f.landlord,
  fa.id as farm_id,
  fa.name as farm_name,
  fa.adams_grain_share,
  COALESCE(f.tenant_share, 1) * COALESCE(fa.adams_grain_share, 1) as effective_share,
  COALESCE(lr.rent_type, 'OWNED') as rent_type,
  CASE WHEN COALESCE(f.tenant_share, 1) < 1 THEN true ELSE false END as has_landlord_split
FROM fields f
JOIN farms fa ON f.farm_id = fa.id
LEFT JOIN be_land_rent lr ON lr.field_id = f.id
WHERE f.active = true;

COMMENT ON VIEW v_field_cost_context IS
'Helper view for breakeven calculations with landlord/tenant context';

-- ============================================================================
-- Split logic summary:
-- ============================================================================
-- HERBICIDE:
--   - application_products.split = 'Y' → split at tenant_share % (shared products)
--   - application_products.split = 'N' → 100% tenant (burndowns, non-residuals)
--
-- FERTILIZER:
--   - ALWAYS split at tenant_share % (all fert is shared with landlord)
--
-- OVERHEAD / SEED / RENT:
--   - NEVER split (100% tenant responsibility)
--
-- BUSHELS:
--   - If tenant_share < 1: tenant gets tenant_share % of bushels
--   - If tenant_share = 1: tenant gets 100% of bushels
-- ============================================================================
