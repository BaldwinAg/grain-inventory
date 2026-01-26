-- ============================================================================
-- Breakeven Calculator Phase 3: Planned vs Actual Costs & Field Visibility
-- ============================================================================

-- Part 1: Add cost_type column to seed costs for planned vs actual tracking
ALTER TABLE be_crop_plan_seed
ADD COLUMN IF NOT EXISTS cost_type VARCHAR(10) DEFAULT 'planned'
  CHECK (cost_type IN ('planned', 'actual'));

-- Part 2: Add cost_type column to fertilizer passes for planned vs actual tracking
ALTER TABLE be_crop_plan_fertilizer
ADD COLUMN IF NOT EXISTS cost_type VARCHAR(10) DEFAULT 'planned'
  CHECK (cost_type IN ('planned', 'actual'));

-- Part 3: Create be_field_settings table for breakeven-specific field visibility
CREATE TABLE IF NOT EXISTS be_field_settings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  field_id UUID NOT NULL REFERENCES fields(id) ON DELETE CASCADE,
  is_active_for_breakeven BOOLEAN DEFAULT true,
  exclude_from_reports BOOLEAN DEFAULT false,
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(field_id)
);

-- Create index for faster lookups
CREATE INDEX IF NOT EXISTS idx_be_field_settings_field_id ON be_field_settings(field_id);
CREATE INDEX IF NOT EXISTS idx_be_field_settings_active ON be_field_settings(is_active_for_breakeven) WHERE is_active_for_breakeven = false;

-- Part 4: Enable RLS on be_field_settings
ALTER TABLE be_field_settings ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if any
DROP POLICY IF EXISTS "Allow authenticated full access on be_field_settings" ON be_field_settings;

-- Create policy for authenticated users
CREATE POLICY "Allow authenticated full access on be_field_settings" ON be_field_settings
  FOR ALL TO authenticated USING (true) WITH CHECK (true);

-- Part 5: Create a table to store profitability price settings per crop year
CREATE TABLE IF NOT EXISTS be_profitability_prices (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  crop_year INTEGER NOT NULL,
  commodity_id UUID NOT NULL REFERENCES commodities(id),
  price_source VARCHAR(20) DEFAULT 'insurance' CHECK (price_source IN ('market', 'insurance', 'manual')),
  manual_price DECIMAL(10, 4),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(crop_year, commodity_id)
);

-- RLS for profitability prices
ALTER TABLE be_profitability_prices ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Allow authenticated full access on be_profitability_prices" ON be_profitability_prices;

CREATE POLICY "Allow authenticated full access on be_profitability_prices" ON be_profitability_prices
  FOR ALL TO authenticated USING (true) WITH CHECK (true);

-- Part 6: Add index for chemical costs tracking from Spray-Suite
-- (No schema changes needed - we query applications table directly)

-- Part 7: Update trigger for be_field_settings updated_at
CREATE OR REPLACE FUNCTION update_be_field_settings_timestamp()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS update_be_field_settings_timestamp ON be_field_settings;

CREATE TRIGGER update_be_field_settings_timestamp
  BEFORE UPDATE ON be_field_settings
  FOR EACH ROW
  EXECUTE FUNCTION update_be_field_settings_timestamp();

-- Part 8: Update trigger for be_profitability_prices updated_at
CREATE OR REPLACE FUNCTION update_be_profitability_prices_timestamp()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS update_be_profitability_prices_timestamp ON be_profitability_prices;

CREATE TRIGGER update_be_profitability_prices_timestamp
  BEFORE UPDATE ON be_profitability_prices
  FOR EACH ROW
  EXECUTE FUNCTION update_be_profitability_prices_timestamp();

-- ============================================================================
-- Comments on the design
-- ============================================================================
--
-- PLANNED VS ACTUAL COSTS:
-- - Seed and fertilizer entries can be flagged as 'planned' or 'actual'
-- - Chemical costs are pulled directly from Spray-Suite applications table
-- - Variance view shows: planned crop plan costs vs actual (modified entries + Spray-Suite actuals)
--
-- FIELD VISIBILITY:
-- - be_field_settings allows excluding specific fields from Breakeven reports
-- - Default is is_active_for_breakeven = true
-- - Fields with farms where adams_grain_share = 0 are already excluded (Dwight farms)
-- - Additional exclusions like "Cleanout" fields handled via be_field_settings
--
-- PROFITABILITY PRICING:
-- - be_profitability_prices stores user selection per commodity per crop year
-- - price_source can be 'market' (from GrainTrack), 'insurance' (from insurance_settings), or 'manual'
-- - Manual price allows override for specific scenarios
-- ============================================================================
