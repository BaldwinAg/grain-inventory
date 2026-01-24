-- ============================================================================
-- BREAKEVEN CALCULATOR: SEED PRODUCTS CATALOG
-- Run this in Supabase SQL Editor
-- ============================================================================

-- ============================================================================
-- SEED PRODUCTS TABLE
-- Catalog of seed products with pricing (like chemical products in Spray-Suite)
-- ============================================================================
CREATE TABLE IF NOT EXISTS be_seed_products (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  commodity_id UUID REFERENCES commodities(id),
  brand VARCHAR(100) NOT NULL,           -- 'Pioneer', 'Dekalb', 'Asgrow', 'NK'
  hybrid VARCHAR(100) NOT NULL,          -- 'P1185AM', 'DKC64-35', 'AG36X6'
  relative_maturity VARCHAR(20),         -- '111 day', '3.6', etc.
  traits TEXT,                           -- 'SmartStax Pro', 'Enlist E3', 'XtendFlex'
  seeds_per_bag INTEGER NOT NULL,        -- 80000 for corn, 140000 for beans
  price_per_bag DECIMAL(10,2),           -- Current price
  default_seeding_rate INTEGER,          -- Default seeds/acre (34000 corn, 140000 beans)
  practice_type VARCHAR(10),             -- 'IR', 'DL', NULL (either)
  notes TEXT,
  active BOOLEAN DEFAULT true,
  deleted_at TIMESTAMPTZ DEFAULT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_be_seed_products_commodity ON be_seed_products(commodity_id);
CREATE INDEX IF NOT EXISTS idx_be_seed_products_brand ON be_seed_products(brand);

COMMENT ON TABLE be_seed_products IS 'Catalog of seed products with pricing for breakeven calculations';

-- ============================================================================
-- UPDATE CROP PLAN SEED TABLE
-- Add reference to seed product (optional - can still use manual entry)
-- ============================================================================
ALTER TABLE be_crop_plan_seed
ADD COLUMN IF NOT EXISTS seed_product_id UUID REFERENCES be_seed_products(id);

COMMENT ON COLUMN be_crop_plan_seed.seed_product_id IS 'Optional reference to seed product catalog. If set, inherits brand/hybrid/price from product.';

-- ============================================================================
-- UPDATE FIELD PLAN ASSIGNMENTS
-- Add seed product override capability
-- ============================================================================
ALTER TABLE be_field_plan_assignments
ADD COLUMN IF NOT EXISTS seed_product_id UUID REFERENCES be_seed_products(id);

COMMENT ON COLUMN be_field_plan_assignments.seed_product_id IS 'Override seed product for this specific field assignment';

-- ============================================================================
-- ROW LEVEL SECURITY
-- ============================================================================
ALTER TABLE be_seed_products ENABLE ROW LEVEL SECURITY;

-- Policies for authenticated users
CREATE POLICY "Allow authenticated read be_seed_products"
ON be_seed_products FOR SELECT TO authenticated USING (true);

CREATE POLICY "Allow authenticated insert be_seed_products"
ON be_seed_products FOR INSERT TO authenticated WITH CHECK (true);

CREATE POLICY "Allow authenticated update be_seed_products"
ON be_seed_products FOR UPDATE TO authenticated USING (true);

CREATE POLICY "Allow authenticated delete be_seed_products"
ON be_seed_products FOR DELETE TO authenticated USING (true);

-- Policies for anonymous users (read-only)
CREATE POLICY "Allow anon read be_seed_products"
ON be_seed_products FOR SELECT TO anon USING (true);

-- ============================================================================
-- GRANTS
-- ============================================================================
GRANT ALL ON be_seed_products TO authenticated;
GRANT SELECT ON be_seed_products TO anon;

-- ============================================================================
-- VERIFICATION
-- ============================================================================
-- SELECT column_name, data_type FROM information_schema.columns WHERE table_name = 'be_seed_products';
-- SELECT column_name, data_type FROM information_schema.columns WHERE table_name = 'be_crop_plan_seed' AND column_name = 'seed_product_id';
-- SELECT column_name, data_type FROM information_schema.columns WHERE table_name = 'be_field_plan_assignments' AND column_name = 'seed_product_id';
