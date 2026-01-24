-- ============================================================================
-- Farm Management Suite - Database Migration
-- Fertilizer App + Breakeven Calculator Tables
-- ============================================================================
-- Run this migration after the existing grain-inventory and spray-suite tables
-- ============================================================================

-- ============================================================================
-- PART 1: FERTILIZER APP TABLES
-- ============================================================================

-- ----------------------------------------------------------------------------
-- FERTILIZER PRODUCTS
-- Master list of fertilizer products with N-P-K content
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS fert_products (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(100) NOT NULL,           -- 'NH3', 'UAN 32%', 'MAP 11-52-0'
  form VARCHAR(20) NOT NULL,            -- 'Anhydrous', 'Liquid', 'Dry'
  unit VARCHAR(20) NOT NULL,            -- 'lb', 'gal', 'ton'
  n_percent DECIMAL(5,2) DEFAULT 0,
  p_percent DECIMAL(5,2) DEFAULT 0,
  k_percent DECIMAL(5,2) DEFAULT 0,
  default_price DECIMAL(10,2),
  active BOOLEAN DEFAULT true,
  deleted_at TIMESTAMPTZ DEFAULT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

COMMENT ON TABLE fert_products IS 'Fertilizer products catalog with N-P-K content';
COMMENT ON COLUMN fert_products.form IS 'Product form: Anhydrous, Liquid, Dry';
COMMENT ON COLUMN fert_products.n_percent IS 'Nitrogen content percentage';
COMMENT ON COLUMN fert_products.p_percent IS 'Phosphorus content percentage (as P2O5)';
COMMENT ON COLUMN fert_products.k_percent IS 'Potassium content percentage (as K2O)';

-- ----------------------------------------------------------------------------
-- PREPAID FERTILIZER (inventory bought ahead)
-- Track fertilizer purchased in advance for future crop years
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS fert_prepaid (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  product_id UUID NOT NULL REFERENCES fert_products(id),
  crop_year INTEGER NOT NULL,
  quantity DECIMAL(12,2) NOT NULL,
  quantity_remaining DECIMAL(12,2) NOT NULL,
  price_per_unit DECIMAL(10,4) NOT NULL,
  purchase_date DATE,
  supplier VARCHAR(100),
  invoice_number VARCHAR(50),
  notes TEXT,
  deleted_at TIMESTAMPTZ DEFAULT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),

  CONSTRAINT positive_fert_quantity CHECK (quantity > 0),
  CONSTRAINT valid_fert_remaining CHECK (quantity_remaining >= 0 AND quantity_remaining <= quantity)
);

COMMENT ON TABLE fert_prepaid IS 'Prepaid fertilizer inventory bought ahead for future use';
COMMENT ON COLUMN fert_prepaid.quantity_remaining IS 'Decreases as applications are made';

-- ----------------------------------------------------------------------------
-- FERTILIZER PLANS (templates for application)
-- Similar to spray-suite tank_mixes but for fertilizer
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS fert_plans (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(100) NOT NULL,           -- 'NH3 Corn Pre-Plant', 'UAN Side-Dress'
  commodity_id UUID REFERENCES commodities(id),
  description TEXT,
  active BOOLEAN DEFAULT true,
  deleted_at TIMESTAMPTZ DEFAULT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

COMMENT ON TABLE fert_plans IS 'Fertilizer application plan templates';

CREATE TABLE IF NOT EXISTS fert_plan_products (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  plan_id UUID NOT NULL REFERENCES fert_plans(id) ON DELETE CASCADE,
  product_id UUID NOT NULL REFERENCES fert_products(id),
  rate DECIMAL(10,2) NOT NULL,          -- Amount per acre
  rate_unit VARCHAR(20) NOT NULL,       -- 'lb/ac', 'gal/ac', 'ton/ac'
  timing VARCHAR(50),                   -- 'Fall', 'Pre-plant', 'Side-dress'
  sort_order INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW(),

  CONSTRAINT positive_fert_rate CHECK (rate > 0)
);

COMMENT ON TABLE fert_plan_products IS 'Products in a fertilizer plan with application rates';

-- ----------------------------------------------------------------------------
-- FERTILIZER APPLICATIONS
-- Track actual fertilizer applications to fields
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS fert_applications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  application_id VARCHAR(20),           -- 'FERT-20260115-001'
  field_id UUID NOT NULL REFERENCES fields(id),
  crop_year INTEGER NOT NULL,
  application_date DATE NOT NULL,
  applicator_id UUID REFERENCES applicators(id),
  plan_id UUID REFERENCES fert_plans(id),
  acres_applied DECIMAL(10,2),
  total_cost DECIMAL(12,2) DEFAULT 0,
  notes TEXT,
  deleted_at TIMESTAMPTZ DEFAULT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

COMMENT ON TABLE fert_applications IS 'Record of fertilizer applications to fields';

CREATE TABLE IF NOT EXISTS fert_application_products (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  application_id UUID NOT NULL REFERENCES fert_applications(id) ON DELETE CASCADE,
  product_id UUID NOT NULL REFERENCES fert_products(id),
  rate DECIMAL(10,4) NOT NULL,
  rate_unit VARCHAR(20) NOT NULL,
  quantity_used DECIMAL(12,2) NOT NULL,
  unit_cost DECIMAL(10,4),              -- From prepaid FIFO or manual
  total_cost DECIMAL(12,2),
  prepaid_id UUID REFERENCES fert_prepaid(id),  -- Link to prepaid lot
  created_at TIMESTAMPTZ DEFAULT NOW(),

  CONSTRAINT positive_fert_app_rate CHECK (rate > 0),
  CONSTRAINT positive_fert_app_qty CHECK (quantity_used > 0)
);

COMMENT ON TABLE fert_application_products IS 'Products used in a fertilizer application with costs';

-- ----------------------------------------------------------------------------
-- SPLIT REPORT IMPORTS (from COOP)
-- Import actual costs from COOP split reports
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS fert_split_imports (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  import_date TIMESTAMPTZ DEFAULT NOW(),
  source VARCHAR(100),                  -- 'MKC', 'Farmers Coop', etc.
  crop_year INTEGER NOT NULL,
  file_name VARCHAR(200),
  total_cost_imported DECIMAL(12,2),
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

COMMENT ON TABLE fert_split_imports IS 'Batch import records for COOP split reports';

CREATE TABLE IF NOT EXISTS fert_split_costs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  import_id UUID REFERENCES fert_split_imports(id),
  field_id UUID REFERENCES fields(id),
  field_name VARCHAR(200),              -- From import, for matching
  product_name VARCHAR(200),
  quantity DECIMAL(12,2),
  unit VARCHAR(20),
  unit_cost DECIMAL(10,4),
  total_cost DECIMAL(12,2),
  crop_year INTEGER NOT NULL,
  matched BOOLEAN DEFAULT false,        -- Has been matched to field
  created_at TIMESTAMPTZ DEFAULT NOW()
);

COMMENT ON TABLE fert_split_costs IS 'Individual cost items from COOP split reports';

-- Fertilizer App Indexes
CREATE INDEX IF NOT EXISTS idx_fert_apps_field ON fert_applications(field_id, crop_year);
CREATE INDEX IF NOT EXISTS idx_fert_apps_date ON fert_applications(application_date DESC);
CREATE INDEX IF NOT EXISTS idx_fert_prepaid_product ON fert_prepaid(product_id, crop_year);
CREATE INDEX IF NOT EXISTS idx_fert_prepaid_available ON fert_prepaid(quantity_remaining) WHERE quantity_remaining > 0;
CREATE INDEX IF NOT EXISTS idx_fert_split_field ON fert_split_costs(field_id, crop_year);
CREATE INDEX IF NOT EXISTS idx_fert_split_unmatched ON fert_split_costs(matched) WHERE matched = false;


-- ============================================================================
-- PART 2: BREAKEVEN CALCULATOR TABLES
-- ============================================================================

-- ----------------------------------------------------------------------------
-- OVERHEAD EXPENSE CATEGORIES
-- Organize overhead expenses by category
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS be_overhead_categories (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(100) NOT NULL,           -- 'Equipment', 'Labor', 'Fixed Costs', 'Misc'
  sort_order INTEGER DEFAULT 0,
  active BOOLEAN DEFAULT true,
  deleted_at TIMESTAMPTZ DEFAULT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

COMMENT ON TABLE be_overhead_categories IS 'Categories for organizing overhead expenses';

-- ----------------------------------------------------------------------------
-- OVERHEAD EXPENSES
-- Farm-level costs allocated to crops/practices
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS be_overhead_expenses (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  category_id UUID REFERENCES be_overhead_categories(id),
  crop_year INTEGER NOT NULL,
  name VARCHAR(200) NOT NULL,           -- 'Planter Payment', 'Hired Labor', 'Property Tax'
  amount DECIMAL(12,2) NOT NULL,
  allocation_type VARCHAR(20) DEFAULT 'ALL_ACRES',  -- 'ALL_ACRES', 'SPECIFIC_CROPS'
  notes TEXT,
  deleted_at TIMESTAMPTZ DEFAULT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),

  CONSTRAINT positive_overhead_amount CHECK (amount >= 0),
  CONSTRAINT valid_allocation_type CHECK (allocation_type IN ('ALL_ACRES', 'SPECIFIC_CROPS'))
);

COMMENT ON TABLE be_overhead_expenses IS 'Farm-level overhead expenses for breakeven calculation';
COMMENT ON COLUMN be_overhead_expenses.allocation_type IS 'ALL_ACRES spreads across all acres, SPECIFIC_CROPS only to selected commodities';

-- ----------------------------------------------------------------------------
-- OVERHEAD ALLOCATIONS
-- Which commodities/practices an overhead expense applies to
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS be_overhead_allocations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  expense_id UUID NOT NULL REFERENCES be_overhead_expenses(id) ON DELETE CASCADE,
  commodity_id UUID NOT NULL REFERENCES commodities(id),
  practice_type VARCHAR(10) DEFAULT NULL,  -- NULL=all, 'IR', 'DL', 'FS', 'DC'
  created_at TIMESTAMPTZ DEFAULT NOW(),

  UNIQUE(expense_id, commodity_id, practice_type)
);

COMMENT ON TABLE be_overhead_allocations IS 'Specifies which crops receive overhead expense allocations';
COMMENT ON COLUMN be_overhead_allocations.practice_type IS 'IR=Irrigated, DL=Dryland, FS=Fallow, DC=Double Crop, NULL=all practices';

-- ----------------------------------------------------------------------------
-- SEED COSTS
-- Simple entry per field for seed cost tracking
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS be_seed_costs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  field_crop_year_id UUID NOT NULL REFERENCES field_crop_years(id),
  variety VARCHAR(200),
  brand VARCHAR(100),
  price_per_bag DECIMAL(10,2),
  seeds_per_bag INTEGER,
  seeding_rate INTEGER,                 -- seeds per acre
  total_cost DECIMAL(12,2),
  notes TEXT,
  deleted_at TIMESTAMPTZ DEFAULT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),

  UNIQUE(field_crop_year_id)
);

COMMENT ON TABLE be_seed_costs IS 'Seed costs per field for breakeven calculation';

-- ----------------------------------------------------------------------------
-- LAND RENT
-- Track cash rent for each field
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS be_land_rent (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  field_id UUID NOT NULL REFERENCES fields(id),
  crop_year INTEGER NOT NULL,
  rent_type VARCHAR(20) DEFAULT 'CASH', -- 'CASH', 'SHARE', 'OWNED'
  rent_per_acre DECIMAL(10,2),
  notes TEXT,
  deleted_at TIMESTAMPTZ DEFAULT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),

  UNIQUE(field_id, crop_year),
  CONSTRAINT valid_rent_type CHECK (rent_type IN ('CASH', 'SHARE', 'OWNED'))
);

COMMENT ON TABLE be_land_rent IS 'Land rent costs per field for breakeven calculation';

-- ----------------------------------------------------------------------------
-- HERBICIDE PLANS (references spray-suite for actual costs)
-- Plan templates that can link to spray-suite tank_mixes
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS be_herbicide_plans (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(100) NOT NULL,           -- 'Burndown Plan', 'Post-emerge Corn'
  commodity_id UUID REFERENCES commodities(id),
  description TEXT,
  tank_mix_id UUID,                     -- References spray-suite tank_mixes(id) if linked
  estimated_cost_per_acre DECIMAL(10,2),
  active BOOLEAN DEFAULT true,
  deleted_at TIMESTAMPTZ DEFAULT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

COMMENT ON TABLE be_herbicide_plans IS 'Herbicide plan templates that can link to spray-suite tank mixes';

-- ----------------------------------------------------------------------------
-- FIELD CROP PLANS
-- Assign plans to specific field crop years
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS be_field_crop_plans (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  field_crop_year_id UUID NOT NULL REFERENCES field_crop_years(id),
  -- Seed assignment
  seed_variety VARCHAR(200),
  seed_brand VARCHAR(100),
  seeding_rate INTEGER,
  -- Fertilizer plan assignment
  fertilizer_plan_id UUID REFERENCES fert_plans(id),
  fertilizer_plan_override DECIMAL(12,2),  -- Override calculated cost if needed
  -- Herbicide plan assignments
  herbicide_cost_override DECIMAL(12,2),   -- Override if not using spray-suite
  -- Other
  notes TEXT,
  deleted_at TIMESTAMPTZ DEFAULT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),

  UNIQUE(field_crop_year_id)
);

COMMENT ON TABLE be_field_crop_plans IS 'Links field_crop_years to input plans for breakeven calculation';

-- ----------------------------------------------------------------------------
-- FIELD HERBICIDE PASSES
-- Multiple herbicide passes per field
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS be_field_herbicide_passes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  field_crop_plan_id UUID NOT NULL REFERENCES be_field_crop_plans(id) ON DELETE CASCADE,
  herbicide_plan_id UUID NOT NULL REFERENCES be_herbicide_plans(id),
  pass_name VARCHAR(50),                -- 'Burndown', 'Post 1', 'Post 2'
  planned_date DATE,
  sort_order INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

COMMENT ON TABLE be_field_herbicide_passes IS 'Individual herbicide passes planned for a field';

-- ----------------------------------------------------------------------------
-- FIELD BREAKEVEN CACHE
-- Cached aggregated calculations from all cost sources
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS be_field_breakeven (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  field_crop_year_id UUID NOT NULL REFERENCES field_crop_years(id),
  crop_year INTEGER NOT NULL,
  commodity_id UUID NOT NULL REFERENCES commodities(id),
  -- Costs (pulled from various sources)
  overhead_cost DECIMAL(12,2) DEFAULT 0,
  seed_cost DECIMAL(12,2) DEFAULT 0,
  land_rent_cost DECIMAL(12,2) DEFAULT 0,
  fertilizer_cost DECIMAL(12,2) DEFAULT 0,    -- From Fertilizer App
  herbicide_cost DECIMAL(12,2) DEFAULT 0,     -- From Spray-Suite
  other_cost DECIMAL(12,2) DEFAULT 0,
  total_cost DECIMAL(12,2) DEFAULT 0,
  -- Production
  acres DECIMAL(10,2) NOT NULL,
  expected_bushels DECIMAL(12,2),
  actual_bushels DECIMAL(12,2),
  -- Breakeven
  breakeven_price DECIMAL(10,4),
  cost_per_acre DECIMAL(10,2),
  is_actual BOOLEAN DEFAULT false,      -- Using actual vs planned costs
  calculated_at TIMESTAMPTZ DEFAULT NOW(),

  UNIQUE(field_crop_year_id)
);

COMMENT ON TABLE be_field_breakeven IS 'Cached breakeven calculations per field';
COMMENT ON COLUMN be_field_breakeven.is_actual IS 'True if using actual costs from applications, false if using planned costs';

-- Breakeven Indexes
CREATE INDEX IF NOT EXISTS idx_be_overhead_year ON be_overhead_expenses(crop_year);
CREATE INDEX IF NOT EXISTS idx_be_overhead_category ON be_overhead_expenses(category_id);
CREATE INDEX IF NOT EXISTS idx_be_seed_fcy ON be_seed_costs(field_crop_year_id);
CREATE INDEX IF NOT EXISTS idx_be_land_rent_field ON be_land_rent(field_id, crop_year);
CREATE INDEX IF NOT EXISTS idx_be_field_plans_fcy ON be_field_crop_plans(field_crop_year_id);
CREATE INDEX IF NOT EXISTS idx_be_breakeven_commodity ON be_field_breakeven(commodity_id, crop_year);
CREATE INDEX IF NOT EXISTS idx_be_breakeven_year ON be_field_breakeven(crop_year);


-- ============================================================================
-- SEED DATA
-- ============================================================================

-- Insert default overhead categories
INSERT INTO be_overhead_categories (name, sort_order) VALUES
  ('Equipment', 1),
  ('Labor', 2),
  ('Fixed Costs', 3),
  ('Insurance', 4),
  ('Miscellaneous', 5)
ON CONFLICT DO NOTHING;

-- Insert common fertilizer products
INSERT INTO fert_products (name, form, unit, n_percent, p_percent, k_percent, default_price) VALUES
  ('NH3 (Anhydrous Ammonia)', 'Anhydrous', 'lb', 82.00, 0, 0, 0.35),
  ('UAN 32%', 'Liquid', 'gal', 32.00, 0, 0, 2.50),
  ('UAN 28%', 'Liquid', 'gal', 28.00, 0, 0, 2.25),
  ('MAP 11-52-0', 'Dry', 'lb', 11.00, 52.00, 0, 0.45),
  ('DAP 18-46-0', 'Dry', 'lb', 18.00, 46.00, 0, 0.42),
  ('Potash 0-0-60', 'Dry', 'lb', 0, 0, 60.00, 0.35),
  ('Urea 46-0-0', 'Dry', 'lb', 46.00, 0, 0, 0.38),
  ('AMS (21-0-0-24S)', 'Dry', 'lb', 21.00, 0, 0, 0.28),
  ('10-34-0', 'Liquid', 'gal', 10.00, 34.00, 0, 3.50),
  ('Sulfur (Elemental)', 'Dry', 'lb', 0, 0, 0, 0.25),
  ('Gypsum (CaSO4)', 'Dry', 'ton', 0, 0, 0, 45.00),
  ('Lime', 'Dry', 'ton', 0, 0, 0, 35.00),
  ('Zinc Sulfate', 'Dry', 'lb', 0, 0, 0, 0.85),
  ('Boron', 'Dry', 'lb', 0, 0, 0, 1.20)
ON CONFLICT DO NOTHING;


-- ============================================================================
-- UPDATE TRIGGER FOR TIMESTAMPS
-- ============================================================================

CREATE OR REPLACE FUNCTION update_farm_suite_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Add updated_at triggers
DROP TRIGGER IF EXISTS trg_be_overhead_updated ON be_overhead_expenses;
CREATE TRIGGER trg_be_overhead_updated
  BEFORE UPDATE ON be_overhead_expenses
  FOR EACH ROW EXECUTE FUNCTION update_farm_suite_updated_at();

DROP TRIGGER IF EXISTS trg_be_field_plans_updated ON be_field_crop_plans;
CREATE TRIGGER trg_be_field_plans_updated
  BEFORE UPDATE ON be_field_crop_plans
  FOR EACH ROW EXECUTE FUNCTION update_farm_suite_updated_at();


-- ============================================================================
-- HELPER FUNCTIONS
-- ============================================================================

-- Function to get FIFO cost for prepaid fertilizer
CREATE OR REPLACE FUNCTION get_fert_fifo_cost(p_product_id UUID, p_crop_year INTEGER)
RETURNS DECIMAL(10,4) AS $$
DECLARE
  avg_cost DECIMAL(10,4);
BEGIN
  SELECT COALESCE(
    SUM(price_per_unit * quantity_remaining) / NULLIF(SUM(quantity_remaining), 0),
    (SELECT default_price FROM fert_products WHERE id = p_product_id)
  )
  INTO avg_cost
  FROM fert_prepaid
  WHERE product_id = p_product_id
    AND crop_year <= p_crop_year
    AND quantity_remaining > 0
    AND deleted_at IS NULL;

  RETURN avg_cost;
END;
$$ LANGUAGE plpgsql;

-- Function to calculate field breakeven
CREATE OR REPLACE FUNCTION calculate_field_breakeven(p_field_crop_year_id UUID)
RETURNS TABLE (
  total_cost DECIMAL(12,2),
  cost_per_acre DECIMAL(10,2),
  breakeven_price DECIMAL(10,4),
  bushels DECIMAL(12,2)
) AS $$
DECLARE
  v_acres DECIMAL(10,2);
  v_bushels DECIMAL(12,2);
  v_overhead DECIMAL(12,2) := 0;
  v_seed DECIMAL(12,2) := 0;
  v_rent DECIMAL(12,2) := 0;
  v_fert DECIMAL(12,2) := 0;
  v_herb DECIMAL(12,2) := 0;
  v_other DECIMAL(12,2) := 0;
  v_total DECIMAL(12,2);
BEGIN
  -- Get acres and production
  SELECT
    fcy.planted_acres,
    COALESCE(fcy.actual_production, fcy.planted_acres * fcy.estimated_yield)
  INTO v_acres, v_bushels
  FROM field_crop_years fcy
  WHERE fcy.id = p_field_crop_year_id;

  IF v_acres IS NULL OR v_acres = 0 THEN
    RETURN QUERY SELECT 0::DECIMAL(12,2), 0::DECIMAL(10,2), NULL::DECIMAL(10,4), 0::DECIMAL(12,2);
    RETURN;
  END IF;

  -- Get seed cost
  SELECT COALESCE(sc.total_cost, 0) INTO v_seed
  FROM be_seed_costs sc
  WHERE sc.field_crop_year_id = p_field_crop_year_id
    AND sc.deleted_at IS NULL;

  -- Get land rent
  SELECT COALESCE(lr.rent_per_acre * v_acres, 0) INTO v_rent
  FROM be_land_rent lr
  JOIN field_crop_years fcy ON fcy.field_id = lr.field_id AND fcy.crop_year = lr.crop_year
  WHERE fcy.id = p_field_crop_year_id
    AND lr.deleted_at IS NULL;

  -- Get fertilizer cost from applications
  SELECT COALESCE(SUM(fa.total_cost), 0) INTO v_fert
  FROM fert_applications fa
  JOIN field_crop_years fcy ON fcy.field_id = fa.field_id AND fcy.crop_year = fa.crop_year
  WHERE fcy.id = p_field_crop_year_id
    AND fa.deleted_at IS NULL;

  -- Get breakeven record for overhead (calculated separately)
  SELECT COALESCE(be.overhead_cost, 0) INTO v_overhead
  FROM be_field_breakeven be
  WHERE be.field_crop_year_id = p_field_crop_year_id;

  -- Calculate totals
  v_total := v_overhead + v_seed + v_rent + v_fert + v_herb + v_other;

  RETURN QUERY SELECT
    v_total,
    CASE WHEN v_acres > 0 THEN v_total / v_acres ELSE 0 END,
    CASE WHEN v_bushels > 0 THEN v_total / v_bushels ELSE NULL END,
    v_bushels;
END;
$$ LANGUAGE plpgsql;

-- Function to get weighted average breakeven for a commodity
CREATE OR REPLACE FUNCTION get_commodity_breakeven(p_commodity_id UUID, p_crop_year INTEGER)
RETURNS DECIMAL(10,4) AS $$
DECLARE
  v_total_cost DECIMAL(12,2);
  v_total_bushels DECIMAL(12,2);
BEGIN
  SELECT
    SUM(be.total_cost),
    SUM(COALESCE(be.actual_bushels, be.expected_bushels))
  INTO v_total_cost, v_total_bushels
  FROM be_field_breakeven be
  WHERE be.commodity_id = p_commodity_id
    AND be.crop_year = p_crop_year;

  IF v_total_bushels IS NULL OR v_total_bushels = 0 THEN
    RETURN NULL;
  END IF;

  RETURN v_total_cost / v_total_bushels;
END;
$$ LANGUAGE plpgsql;


-- ============================================================================
-- ROW LEVEL SECURITY (RLS)
-- ============================================================================

-- Enable RLS on all new tables
ALTER TABLE fert_products ENABLE ROW LEVEL SECURITY;
ALTER TABLE fert_prepaid ENABLE ROW LEVEL SECURITY;
ALTER TABLE fert_plans ENABLE ROW LEVEL SECURITY;
ALTER TABLE fert_plan_products ENABLE ROW LEVEL SECURITY;
ALTER TABLE fert_applications ENABLE ROW LEVEL SECURITY;
ALTER TABLE fert_application_products ENABLE ROW LEVEL SECURITY;
ALTER TABLE fert_split_imports ENABLE ROW LEVEL SECURITY;
ALTER TABLE fert_split_costs ENABLE ROW LEVEL SECURITY;
ALTER TABLE be_overhead_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE be_overhead_expenses ENABLE ROW LEVEL SECURITY;
ALTER TABLE be_overhead_allocations ENABLE ROW LEVEL SECURITY;
ALTER TABLE be_seed_costs ENABLE ROW LEVEL SECURITY;
ALTER TABLE be_land_rent ENABLE ROW LEVEL SECURITY;
ALTER TABLE be_herbicide_plans ENABLE ROW LEVEL SECURITY;
ALTER TABLE be_field_crop_plans ENABLE ROW LEVEL SECURITY;
ALTER TABLE be_field_herbicide_passes ENABLE ROW LEVEL SECURITY;
ALTER TABLE be_field_breakeven ENABLE ROW LEVEL SECURITY;

-- Create policies for authenticated users (same pattern as existing tables)
CREATE POLICY "Allow authenticated read fert_products" ON fert_products FOR SELECT TO authenticated USING (true);
CREATE POLICY "Allow authenticated insert fert_products" ON fert_products FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "Allow authenticated update fert_products" ON fert_products FOR UPDATE TO authenticated USING (true);
CREATE POLICY "Allow authenticated delete fert_products" ON fert_products FOR DELETE TO authenticated USING (true);

CREATE POLICY "Allow authenticated read fert_prepaid" ON fert_prepaid FOR SELECT TO authenticated USING (true);
CREATE POLICY "Allow authenticated insert fert_prepaid" ON fert_prepaid FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "Allow authenticated update fert_prepaid" ON fert_prepaid FOR UPDATE TO authenticated USING (true);
CREATE POLICY "Allow authenticated delete fert_prepaid" ON fert_prepaid FOR DELETE TO authenticated USING (true);

CREATE POLICY "Allow authenticated read fert_plans" ON fert_plans FOR SELECT TO authenticated USING (true);
CREATE POLICY "Allow authenticated insert fert_plans" ON fert_plans FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "Allow authenticated update fert_plans" ON fert_plans FOR UPDATE TO authenticated USING (true);
CREATE POLICY "Allow authenticated delete fert_plans" ON fert_plans FOR DELETE TO authenticated USING (true);

CREATE POLICY "Allow authenticated read fert_plan_products" ON fert_plan_products FOR SELECT TO authenticated USING (true);
CREATE POLICY "Allow authenticated insert fert_plan_products" ON fert_plan_products FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "Allow authenticated update fert_plan_products" ON fert_plan_products FOR UPDATE TO authenticated USING (true);
CREATE POLICY "Allow authenticated delete fert_plan_products" ON fert_plan_products FOR DELETE TO authenticated USING (true);

CREATE POLICY "Allow authenticated read fert_applications" ON fert_applications FOR SELECT TO authenticated USING (true);
CREATE POLICY "Allow authenticated insert fert_applications" ON fert_applications FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "Allow authenticated update fert_applications" ON fert_applications FOR UPDATE TO authenticated USING (true);
CREATE POLICY "Allow authenticated delete fert_applications" ON fert_applications FOR DELETE TO authenticated USING (true);

CREATE POLICY "Allow authenticated read fert_application_products" ON fert_application_products FOR SELECT TO authenticated USING (true);
CREATE POLICY "Allow authenticated insert fert_application_products" ON fert_application_products FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "Allow authenticated update fert_application_products" ON fert_application_products FOR UPDATE TO authenticated USING (true);
CREATE POLICY "Allow authenticated delete fert_application_products" ON fert_application_products FOR DELETE TO authenticated USING (true);

CREATE POLICY "Allow authenticated read fert_split_imports" ON fert_split_imports FOR SELECT TO authenticated USING (true);
CREATE POLICY "Allow authenticated insert fert_split_imports" ON fert_split_imports FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "Allow authenticated update fert_split_imports" ON fert_split_imports FOR UPDATE TO authenticated USING (true);
CREATE POLICY "Allow authenticated delete fert_split_imports" ON fert_split_imports FOR DELETE TO authenticated USING (true);

CREATE POLICY "Allow authenticated read fert_split_costs" ON fert_split_costs FOR SELECT TO authenticated USING (true);
CREATE POLICY "Allow authenticated insert fert_split_costs" ON fert_split_costs FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "Allow authenticated update fert_split_costs" ON fert_split_costs FOR UPDATE TO authenticated USING (true);
CREATE POLICY "Allow authenticated delete fert_split_costs" ON fert_split_costs FOR DELETE TO authenticated USING (true);

CREATE POLICY "Allow authenticated read be_overhead_categories" ON be_overhead_categories FOR SELECT TO authenticated USING (true);
CREATE POLICY "Allow authenticated insert be_overhead_categories" ON be_overhead_categories FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "Allow authenticated update be_overhead_categories" ON be_overhead_categories FOR UPDATE TO authenticated USING (true);
CREATE POLICY "Allow authenticated delete be_overhead_categories" ON be_overhead_categories FOR DELETE TO authenticated USING (true);

CREATE POLICY "Allow authenticated read be_overhead_expenses" ON be_overhead_expenses FOR SELECT TO authenticated USING (true);
CREATE POLICY "Allow authenticated insert be_overhead_expenses" ON be_overhead_expenses FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "Allow authenticated update be_overhead_expenses" ON be_overhead_expenses FOR UPDATE TO authenticated USING (true);
CREATE POLICY "Allow authenticated delete be_overhead_expenses" ON be_overhead_expenses FOR DELETE TO authenticated USING (true);

CREATE POLICY "Allow authenticated read be_overhead_allocations" ON be_overhead_allocations FOR SELECT TO authenticated USING (true);
CREATE POLICY "Allow authenticated insert be_overhead_allocations" ON be_overhead_allocations FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "Allow authenticated update be_overhead_allocations" ON be_overhead_allocations FOR UPDATE TO authenticated USING (true);
CREATE POLICY "Allow authenticated delete be_overhead_allocations" ON be_overhead_allocations FOR DELETE TO authenticated USING (true);

CREATE POLICY "Allow authenticated read be_seed_costs" ON be_seed_costs FOR SELECT TO authenticated USING (true);
CREATE POLICY "Allow authenticated insert be_seed_costs" ON be_seed_costs FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "Allow authenticated update be_seed_costs" ON be_seed_costs FOR UPDATE TO authenticated USING (true);
CREATE POLICY "Allow authenticated delete be_seed_costs" ON be_seed_costs FOR DELETE TO authenticated USING (true);

CREATE POLICY "Allow authenticated read be_land_rent" ON be_land_rent FOR SELECT TO authenticated USING (true);
CREATE POLICY "Allow authenticated insert be_land_rent" ON be_land_rent FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "Allow authenticated update be_land_rent" ON be_land_rent FOR UPDATE TO authenticated USING (true);
CREATE POLICY "Allow authenticated delete be_land_rent" ON be_land_rent FOR DELETE TO authenticated USING (true);

CREATE POLICY "Allow authenticated read be_herbicide_plans" ON be_herbicide_plans FOR SELECT TO authenticated USING (true);
CREATE POLICY "Allow authenticated insert be_herbicide_plans" ON be_herbicide_plans FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "Allow authenticated update be_herbicide_plans" ON be_herbicide_plans FOR UPDATE TO authenticated USING (true);
CREATE POLICY "Allow authenticated delete be_herbicide_plans" ON be_herbicide_plans FOR DELETE TO authenticated USING (true);

CREATE POLICY "Allow authenticated read be_field_crop_plans" ON be_field_crop_plans FOR SELECT TO authenticated USING (true);
CREATE POLICY "Allow authenticated insert be_field_crop_plans" ON be_field_crop_plans FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "Allow authenticated update be_field_crop_plans" ON be_field_crop_plans FOR UPDATE TO authenticated USING (true);
CREATE POLICY "Allow authenticated delete be_field_crop_plans" ON be_field_crop_plans FOR DELETE TO authenticated USING (true);

CREATE POLICY "Allow authenticated read be_field_herbicide_passes" ON be_field_herbicide_passes FOR SELECT TO authenticated USING (true);
CREATE POLICY "Allow authenticated insert be_field_herbicide_passes" ON be_field_herbicide_passes FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "Allow authenticated update be_field_herbicide_passes" ON be_field_herbicide_passes FOR UPDATE TO authenticated USING (true);
CREATE POLICY "Allow authenticated delete be_field_herbicide_passes" ON be_field_herbicide_passes FOR DELETE TO authenticated USING (true);

CREATE POLICY "Allow authenticated read be_field_breakeven" ON be_field_breakeven FOR SELECT TO authenticated USING (true);
CREATE POLICY "Allow authenticated insert be_field_breakeven" ON be_field_breakeven FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "Allow authenticated update be_field_breakeven" ON be_field_breakeven FOR UPDATE TO authenticated USING (true);
CREATE POLICY "Allow authenticated delete be_field_breakeven" ON be_field_breakeven FOR DELETE TO authenticated USING (true);


-- ============================================================================
-- GRANT PERMISSIONS
-- ============================================================================

GRANT ALL ON fert_products TO authenticated;
GRANT ALL ON fert_prepaid TO authenticated;
GRANT ALL ON fert_plans TO authenticated;
GRANT ALL ON fert_plan_products TO authenticated;
GRANT ALL ON fert_applications TO authenticated;
GRANT ALL ON fert_application_products TO authenticated;
GRANT ALL ON fert_split_imports TO authenticated;
GRANT ALL ON fert_split_costs TO authenticated;
GRANT ALL ON be_overhead_categories TO authenticated;
GRANT ALL ON be_overhead_expenses TO authenticated;
GRANT ALL ON be_overhead_allocations TO authenticated;
GRANT ALL ON be_seed_costs TO authenticated;
GRANT ALL ON be_land_rent TO authenticated;
GRANT ALL ON be_herbicide_plans TO authenticated;
GRANT ALL ON be_field_crop_plans TO authenticated;
GRANT ALL ON be_field_herbicide_passes TO authenticated;
GRANT ALL ON be_field_breakeven TO authenticated;
