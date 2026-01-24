-- ============================================================================
-- BREAKEVEN CALCULATOR PHASE 2: COMPREHENSIVE CROP PLANS
-- Run this in Supabase SQL Editor
-- ============================================================================

-- ============================================================================
-- MAIN CROP PLANS TABLE
-- ============================================================================
CREATE TABLE IF NOT EXISTS be_crop_plans (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(100) NOT NULL,           -- '2026 Irrigated Corn', '2026 Dryland Beans'
  commodity_id UUID REFERENCES commodities(id),
  practice_type VARCHAR(10),            -- 'IR', 'DL', NULL (any)
  crop_year INTEGER NOT NULL,
  description TEXT,
  active BOOLEAN DEFAULT true,
  deleted_at TIMESTAMPTZ DEFAULT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_be_crop_plans_year ON be_crop_plans(crop_year);
CREATE INDEX IF NOT EXISTS idx_be_crop_plans_commodity ON be_crop_plans(commodity_id);

-- ============================================================================
-- SEED SECTION (one seed config per plan)
-- ============================================================================
CREATE TABLE IF NOT EXISTS be_crop_plan_seed (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  crop_plan_id UUID NOT NULL REFERENCES be_crop_plans(id) ON DELETE CASCADE,
  brand VARCHAR(100),                   -- 'Pioneer', 'Dekalb', 'Asgrow'
  hybrid VARCHAR(100),                  -- 'P1185AM', 'DKC64-35'
  seeds_per_bag INTEGER DEFAULT 80000,  -- 80000 corn, 140000 beans
  price_per_bag DECIMAL(10,2),          -- $350
  default_seeding_rate INTEGER,         -- seeds/acre (e.g., 34000)
  treatment VARCHAR(100),               -- 'Poncho/Votivo', 'Acceleron'
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(crop_plan_id)
);

-- ============================================================================
-- CUSTOM COSTS (tillage, custom hire, drying, etc.)
-- ============================================================================
CREATE TABLE IF NOT EXISTS be_crop_plan_custom_costs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  crop_plan_id UUID NOT NULL REFERENCES be_crop_plans(id) ON DELETE CASCADE,
  name VARCHAR(100) NOT NULL,           -- 'Custom Disk', 'Aerial Application', 'Drying'
  cost_type VARCHAR(20) NOT NULL,       -- 'PER_ACRE', 'PER_BUSHEL', 'FIXED'
  amount DECIMAL(10,4) NOT NULL,        -- Cost amount
  unit VARCHAR(30),                     -- '/acre', '/bu', '/point/bu', 'total'
  timing VARCHAR(50),                   -- 'Pre-plant', 'In-season', 'Harvest', 'Post-harvest'
  notes TEXT,
  sort_order INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_be_crop_plan_custom_plan ON be_crop_plan_custom_costs(crop_plan_id);

-- ============================================================================
-- FERTILIZER PASSES (multiple applications per plan)
-- ============================================================================
CREATE TABLE IF NOT EXISTS be_crop_plan_fertilizer (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  crop_plan_id UUID NOT NULL REFERENCES be_crop_plans(id) ON DELETE CASCADE,
  pass_name VARCHAR(50) NOT NULL,       -- 'Fall NH3', 'Spring MAP', 'Side-dress UAN'
  timing VARCHAR(50),                   -- 'Fall', 'Pre-plant', 'At-plant', 'Side-dress'
  application_method VARCHAR(50),       -- 'Anhydrous', 'Broadcast', 'Injected', 'Foliar'
  notes TEXT,
  sort_order INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_be_crop_plan_fert_plan ON be_crop_plan_fertilizer(crop_plan_id);

-- ============================================================================
-- FERTILIZER PRODUCTS PER PASS
-- ============================================================================
CREATE TABLE IF NOT EXISTS be_crop_plan_fertilizer_products (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  fertilizer_pass_id UUID NOT NULL REFERENCES be_crop_plan_fertilizer(id) ON DELETE CASCADE,
  product_id UUID REFERENCES fert_products(id),  -- Link to fertilizer app products
  product_name VARCHAR(100),            -- Fallback if no product_id: 'NH3', 'MAP 11-52-0'
  rate DECIMAL(10,4) NOT NULL,          -- Amount per acre
  rate_unit VARCHAR(20) NOT NULL,       -- 'lb/acre', 'gal/acre', 'ton/acre'
  price_per_unit DECIMAL(10,4),         -- Default price for planning
  notes TEXT,
  sort_order INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_be_crop_plan_fert_prod_pass ON be_crop_plan_fertilizer_products(fertilizer_pass_id);

-- ============================================================================
-- CHEMICAL PASSES (multiple applications per plan)
-- ============================================================================
CREATE TABLE IF NOT EXISTS be_crop_plan_chemicals (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  crop_plan_id UUID NOT NULL REFERENCES be_crop_plans(id) ON DELETE CASCADE,
  pass_name VARCHAR(50) NOT NULL,       -- 'Burndown', 'Pre-Emerge', 'Post-Emerge 1'
  timing VARCHAR(50),                   -- 'Pre-plant', 'At-plant', 'Post-emerge', 'Layby'
  tank_mix_id UUID,                     -- Link to spray-suite tank_mixes for actual costs
  application_method VARCHAR(50),       -- 'Ground', 'Aerial'
  notes TEXT,
  sort_order INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_be_crop_plan_chem_plan ON be_crop_plan_chemicals(crop_plan_id);

-- ============================================================================
-- CHEMICAL PRODUCTS PER PASS
-- ============================================================================
CREATE TABLE IF NOT EXISTS be_crop_plan_chemical_products (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  chemical_pass_id UUID NOT NULL REFERENCES be_crop_plan_chemicals(id) ON DELETE CASCADE,
  product_id UUID,                      -- Link to spray-suite products
  product_name VARCHAR(100),            -- Fallback: 'Roundup PowerMax', 'Atrazine 4L'
  rate DECIMAL(10,4) NOT NULL,          -- Amount per acre
  rate_unit VARCHAR(20) NOT NULL,       -- 'oz/acre', 'pt/acre', 'qt/acre', 'gal/acre'
  price_per_unit DECIMAL(10,4),         -- Default price for planning
  notes TEXT,
  sort_order INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_be_crop_plan_chem_prod_pass ON be_crop_plan_chemical_products(chemical_pass_id);

-- ============================================================================
-- ROW LEVEL SECURITY (if needed)
-- ============================================================================
-- ALTER TABLE be_crop_plans ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE be_crop_plan_seed ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE be_crop_plan_custom_costs ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE be_crop_plan_fertilizer ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE be_crop_plan_fertilizer_products ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE be_crop_plan_chemicals ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE be_crop_plan_chemical_products ENABLE ROW LEVEL SECURITY;

-- ============================================================================
-- VERIFICATION QUERIES
-- ============================================================================
-- SELECT table_name FROM information_schema.tables WHERE table_name LIKE 'be_crop_plan%';
