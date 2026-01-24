-- ============================================================================
-- BREAKEVEN CALCULATOR COMPREHENSIVE REDESIGN
-- New tables for Misc Income, Actual Costs, and Enhanced Field Breakeven
-- Run this in Supabase SQL Editor
-- ============================================================================

-- ============================================================================
-- MISC INCOME CATEGORIES
-- ============================================================================
CREATE TABLE IF NOT EXISTS be_misc_income_categories (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(100) NOT NULL,           -- 'Government', 'Conservation', 'Insurance', 'Other'
  description TEXT,
  sort_order INTEGER DEFAULT 0,
  active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Insert default categories
INSERT INTO be_misc_income_categories (name, description, sort_order)
VALUES
  ('Government', 'Farm program payments: ARC-CO, ARC-IC, PLC, MFP, Ad Hoc', 1),
  ('Conservation', 'Conservation payments: CRP, EQIP, CSP', 2),
  ('Insurance', 'Crop insurance indemnities and prevented planting', 3),
  ('Other', 'Miscellaneous farm income', 4)
ON CONFLICT DO NOTHING;

-- ============================================================================
-- MISC INCOME
-- Track income that offsets costs (government payments, conservation, etc.)
-- ============================================================================
CREATE TABLE IF NOT EXISTS be_misc_income (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  category_id UUID REFERENCES be_misc_income_categories(id),
  crop_year INTEGER NOT NULL,
  name VARCHAR(200) NOT NULL,           -- 'ARC-CO Corn', 'CRP Annual', 'Prevented Planting'
  income_type VARCHAR(20) NOT NULL,     -- 'TOTAL', 'PER_ACRE', 'PER_BUSHEL'
  amount DECIMAL(12,2) NOT NULL,        -- The value (total amount, or per-acre/per-bushel rate)

  -- Allocation method
  allocation_type VARCHAR(30) DEFAULT 'ALL_ACRES', -- 'ALL_ACRES', 'SPECIFIC_CROPS', 'SPECIFIC_FIELDS'

  -- For specific allocation to a commodity
  commodity_id UUID REFERENCES commodities(id),

  -- Status tracking
  is_projected BOOLEAN DEFAULT true,    -- Estimated vs actually received
  payment_date DATE,                    -- When received (if applicable)

  notes TEXT,
  deleted_at TIMESTAMPTZ DEFAULT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_be_misc_income_year ON be_misc_income(crop_year);
CREATE INDEX IF NOT EXISTS idx_be_misc_income_category ON be_misc_income(category_id);
CREATE INDEX IF NOT EXISTS idx_be_misc_income_commodity ON be_misc_income(commodity_id);

-- ============================================================================
-- MISC INCOME ALLOCATIONS
-- For specific field or commodity allocations
-- ============================================================================
CREATE TABLE IF NOT EXISTS be_misc_income_allocations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  income_id UUID NOT NULL REFERENCES be_misc_income(id) ON DELETE CASCADE,
  commodity_id UUID REFERENCES commodities(id),
  field_id UUID REFERENCES fields(id),
  practice_type VARCHAR(10),            -- 'IR', 'DL', NULL
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_be_misc_income_alloc_income ON be_misc_income_allocations(income_id);

-- ============================================================================
-- ACTUAL COSTS TRACKING
-- Track planned vs actual costs for variance analysis
-- ============================================================================
CREATE TABLE IF NOT EXISTS be_actual_costs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  field_crop_year_id UUID NOT NULL REFERENCES field_crop_years(id),
  cost_type VARCHAR(20) NOT NULL,       -- 'SEED', 'CUSTOM', 'FERTILIZER', 'CHEMICAL', 'OVERHEAD', 'RENT'
  description VARCHAR(200),             -- Description of cost item

  -- Planned vs Actual
  planned_cost DECIMAL(12,2),           -- From crop plan or breakeven entry
  actual_cost DECIMAL(12,2),            -- Entered manually or pulled from apps

  -- Source tracking
  source_type VARCHAR(20),              -- 'MANUAL', 'SPRAY_SUITE', 'FERT_APP', 'CROP_PLAN'
  source_id UUID,                       -- ID in source system (for linking)

  -- Per-acre values (for display)
  planned_per_acre DECIMAL(10,4),
  actual_per_acre DECIMAL(10,4),

  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_be_actual_costs_fcy ON be_actual_costs(field_crop_year_id);
CREATE INDEX IF NOT EXISTS idx_be_actual_costs_type ON be_actual_costs(cost_type);

-- ============================================================================
-- FIELD BREAKEVEN CACHE
-- Stores calculated breakeven data for faster retrieval
-- ============================================================================
CREATE TABLE IF NOT EXISTS be_field_breakeven (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  field_crop_year_id UUID NOT NULL REFERENCES field_crop_years(id) UNIQUE,

  -- Total costs (without ownership adjustment)
  total_overhead DECIMAL(12,2) DEFAULT 0,
  total_seed DECIMAL(12,2) DEFAULT 0,
  total_rent DECIMAL(12,2) DEFAULT 0,
  total_fertilizer DECIMAL(12,2) DEFAULT 0,
  total_herbicide DECIMAL(12,2) DEFAULT 0,
  total_cost DECIMAL(12,2) DEFAULT 0,

  -- Planned vs Actual breakdowns
  planned_total_cost DECIMAL(12,2) DEFAULT 0,
  actual_total_cost DECIMAL(12,2) DEFAULT 0,

  -- Income offset
  income_offset DECIMAL(12,2) DEFAULT 0,
  net_cost DECIMAL(12,2) DEFAULT 0,     -- total_cost - income_offset

  -- Breakeven prices
  breakeven_price DECIMAL(10,4),        -- Net cost / bushels
  planned_breakeven DECIMAL(10,4),
  actual_breakeven DECIMAL(10,4),

  -- Per-acre values
  cost_per_acre DECIMAL(10,4),
  planned_cost_per_acre DECIMAL(10,4),
  actual_cost_per_acre DECIMAL(10,4),

  -- Ownership-adjusted values (your share)
  your_share_cost DECIMAL(12,2) DEFAULT 0,
  your_share_bushels DECIMAL(12,2) DEFAULT 0,
  your_share_breakeven DECIMAL(10,4),

  last_calculated TIMESTAMPTZ DEFAULT NOW(),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_be_field_breakeven_fcy ON be_field_breakeven(field_crop_year_id);

-- ============================================================================
-- UTILITY FUNCTIONS
-- ============================================================================

-- Function to calculate variance percentage
CREATE OR REPLACE FUNCTION calculate_variance_pct(planned DECIMAL, actual DECIMAL)
RETURNS DECIMAL AS $$
BEGIN
  IF planned IS NULL OR planned = 0 THEN
    RETURN NULL;
  END IF;
  RETURN ROUND(((actual - planned) / planned) * 100, 2);
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- VERIFICATION QUERIES
-- ============================================================================
-- SELECT table_name FROM information_schema.tables WHERE table_name LIKE 'be_misc%' OR table_name LIKE 'be_actual%' OR table_name = 'be_field_breakeven';
