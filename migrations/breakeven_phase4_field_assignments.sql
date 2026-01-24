-- ============================================================================
-- BREAKEVEN CALCULATOR PHASE 4: FIELD PLAN ASSIGNMENTS
-- Run this in Supabase SQL Editor
-- ============================================================================

-- ============================================================================
-- FIELD PLAN ASSIGNMENTS
-- Assigns comprehensive crop plans to individual fields with override capability
-- ============================================================================
CREATE TABLE IF NOT EXISTS be_field_plan_assignments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  field_crop_year_id UUID NOT NULL REFERENCES field_crop_years(id),
  crop_plan_id UUID NOT NULL REFERENCES be_crop_plans(id),

  -- SEED OVERRIDES (NULL = use plan defaults)
  seed_override_hybrid VARCHAR(100),
  seed_override_brand VARCHAR(100),
  seed_override_rate INTEGER,           -- seeds/acre
  seed_override_price DECIMAL(10,2),    -- price/bag

  -- Status tracking
  status VARCHAR(20) DEFAULT 'PLANNED', -- 'PLANNED', 'IN_PROGRESS', 'COMPLETED'

  notes TEXT,
  deleted_at TIMESTAMPTZ DEFAULT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(field_crop_year_id)
);

CREATE INDEX IF NOT EXISTS idx_be_field_assignments_fcy ON be_field_plan_assignments(field_crop_year_id);
CREATE INDEX IF NOT EXISTS idx_be_field_assignments_plan ON be_field_plan_assignments(crop_plan_id);

-- ============================================================================
-- FIELD CUSTOM COST OVERRIDES
-- Allow skipping or adjusting specific costs per field
-- ============================================================================
CREATE TABLE IF NOT EXISTS be_field_custom_cost_overrides (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  assignment_id UUID NOT NULL REFERENCES be_field_plan_assignments(id) ON DELETE CASCADE,
  plan_custom_cost_id UUID REFERENCES be_crop_plan_custom_costs(id),
  override_amount DECIMAL(10,4),
  skip_this_cost BOOLEAN DEFAULT false, -- Exclude from this field
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_be_field_overrides_assign ON be_field_custom_cost_overrides(assignment_id);

-- ============================================================================
-- VERIFICATION QUERIES
-- ============================================================================
-- SELECT table_name FROM information_schema.tables WHERE table_name LIKE 'be_field%';
