-- ============================================================================
-- Add split_with_landlord to Spray-Suite application_products
-- This controls whether a specific product in an application is split with landlord
-- ============================================================================

-- Add column to application_products (Spray-Suite)
ALTER TABLE application_products
ADD COLUMN IF NOT EXISTS split_with_landlord BOOLEAN DEFAULT false;

COMMENT ON COLUMN application_products.split_with_landlord IS
'If true, cost is split with landlord at grain share %.
Burndowns = false (100% tenant, replaces tillage)
In-crop = true (split)
At-planting residuals = true (always split)
At-planting non-residuals = false (100% tenant)';

-- Also add to fert_application_products for fertilizer (always split, but column for consistency)
ALTER TABLE fert_application_products
ADD COLUMN IF NOT EXISTS split_with_landlord BOOLEAN DEFAULT true;

COMMENT ON COLUMN fert_application_products.split_with_landlord IS
'Fertilizer is always split with landlord at grain share %. Default true.';

-- ============================================================================
-- Add rent_type context for breakeven calculations
-- Cash rent = 100% tenant (all costs / total production)
-- Share crop = split by tenant_share
-- ============================================================================

-- Ensure be_land_rent has rent_type with proper values
-- (Already exists from farm_management_suite.sql, but ensure it's used correctly)

-- View to help with cost calculations
CREATE OR REPLACE VIEW v_field_cost_context AS
SELECT
  f.id as field_id,
  f.name as field_name,
  f.tenant_share,
  f.landlord,
  fa.name as farm_name,
  fa.adams_grain_share,
  COALESCE(f.tenant_share, 1) * COALESCE(fa.adams_grain_share, 1) as effective_share,
  COALESCE(lr.rent_type, 'OWNED') as rent_type,
  CASE
    WHEN COALESCE(lr.rent_type, 'OWNED') = 'SHARE' THEN true
    ELSE false
  END as is_share_crop,
  CASE
    WHEN COALESCE(lr.rent_type, 'OWNED') IN ('CASH', 'OWNED') THEN true
    ELSE false
  END as is_cash_or_owned
FROM fields f
JOIN farms fa ON f.farm_id = fa.id
LEFT JOIN be_land_rent lr ON lr.field_id = f.id
WHERE f.active = true;

COMMENT ON VIEW v_field_cost_context IS
'Helper view for breakeven calculations with landlord/tenant context';
