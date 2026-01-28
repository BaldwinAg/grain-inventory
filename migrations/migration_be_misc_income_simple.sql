-- Simplified Migration: Create be_misc_income tables
-- Purpose: Track miscellaneous income (insurance payments, USDA programs, etc.)
-- Note: This is a simplified version without RLS for easier debugging

-- Drop tables if they exist (clean slate)
DROP TABLE IF EXISTS be_misc_income_allocations CASCADE;
DROP TABLE IF EXISTS be_misc_income CASCADE;
DROP TABLE IF EXISTS be_misc_income_categories CASCADE;

-- Create be_misc_income_categories table
CREATE TABLE be_misc_income_categories (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  description TEXT,
  sort_order INTEGER DEFAULT 0,
  active BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create be_misc_income table
CREATE TABLE be_misc_income (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  category_id UUID REFERENCES be_misc_income_categories(id) ON DELETE SET NULL,
  crop_year INTEGER NOT NULL,
  name TEXT NOT NULL,
  income_type TEXT DEFAULT 'TOTAL', -- 'TOTAL' (lump sum) or 'PER_ACRE' (calculated per acre)
  amount NUMERIC(12,2) NOT NULL DEFAULT 0,
  notes TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  deleted_at TIMESTAMP WITH TIME ZONE
);

-- Create be_misc_income_allocations table
-- Tracks how misc income is allocated to specific commodities/fields/practices
CREATE TABLE be_misc_income_allocations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  income_id UUID NOT NULL REFERENCES be_misc_income(id) ON DELETE CASCADE,
  commodity_id UUID REFERENCES commodities(id) ON DELETE CASCADE,
  field_id UUID REFERENCES fields(id) ON DELETE CASCADE,
  practice_type TEXT, -- 'IR' (irrigated), 'DL' (dryland), 'FS', 'DC', etc.
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes for better query performance
CREATE INDEX idx_misc_income_crop_year ON be_misc_income(crop_year);
CREATE INDEX idx_misc_income_deleted_at ON be_misc_income(deleted_at);
CREATE INDEX idx_misc_income_category_id ON be_misc_income(category_id);
CREATE INDEX idx_misc_income_allocations_income_id ON be_misc_income_allocations(income_id);
CREATE INDEX idx_misc_income_allocations_commodity_id ON be_misc_income_allocations(commodity_id);
CREATE INDEX idx_misc_income_allocations_field_id ON be_misc_income_allocations(field_id);

-- Insert default categories
INSERT INTO be_misc_income_categories (name, description, sort_order) VALUES
  ('Insurance', 'Crop insurance payments', 1),
  ('USDA Programs', 'Government program payments (ARC, PLC, etc.)', 2),
  ('Conservation', 'CRP, CSP, EQIP payments', 3),
  ('Other', 'Other miscellaneous income', 99);

-- Add comments
COMMENT ON TABLE be_misc_income_categories IS 'Categories for miscellaneous income (insurance, USDA programs, etc.)';
COMMENT ON TABLE be_misc_income IS 'Miscellaneous income entries for crop years';
COMMENT ON TABLE be_misc_income_allocations IS 'Allocates misc income to specific commodities, fields, or practice types';

COMMENT ON COLUMN be_misc_income.income_type IS 'TOTAL = lump sum amount, PER_ACRE = calculated per acre';
COMMENT ON COLUMN be_misc_income_allocations.practice_type IS 'Optional: IR (irrigated), DL (dryland), FS, DC, etc.';

-- Verify tables were created
SELECT
  schemaname,
  tablename,
  'Created successfully' as status
FROM pg_tables
WHERE tablename LIKE 'be_misc_income%'
ORDER BY tablename;
