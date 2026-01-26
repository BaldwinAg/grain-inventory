-- Fix insurance schema: Remove insurance fields from field_crop_years, keep only APH
-- Insurance coverage/reference/policy are centralized in insurance_settings table

-- First, drop the columns we added incorrectly to field_crop_years
ALTER TABLE field_crop_years DROP COLUMN IF EXISTS coverage_level;
ALTER TABLE field_crop_years DROP COLUMN IF EXISTS reference_price;
ALTER TABLE field_crop_years DROP COLUMN IF EXISTS policy_type;

-- Keep aph_yield in field_crop_years (field-specific)
ALTER TABLE field_crop_years ADD COLUMN IF NOT EXISTS aph_yield DECIMAL(10,2) DEFAULT NULL;

-- Update insurance_settings table to handle reference price and commodity-level vs practice-level coverage
-- Existing columns: commodity_id, crop_year, practice_type, coverage_level, policy_type
-- Add reference_price column
ALTER TABLE insurance_settings ADD COLUMN IF NOT EXISTS reference_price DECIMAL(10,2) DEFAULT NULL;

-- Add comments
COMMENT ON COLUMN field_crop_years.aph_yield IS 'Actual Production History yield (bu/acre) - field-specific insurance yield';
COMMENT ON COLUMN insurance_settings.reference_price IS 'Reference/Projected price for insurance - set per commodity per year';
COMMENT ON COLUMN insurance_settings.practice_type IS 'NULL = commodity level, IR/DL/FS/DC = practice-specific coverage';
COMMENT ON COLUMN insurance_settings.coverage_level IS 'Coverage level (0.70 = 70%, 0.75 = 75%, etc.)';

-- Add index for insurance queries
CREATE INDEX IF NOT EXISTS idx_field_crop_years_aph
  ON field_crop_years(crop_year, commodity_id)
  WHERE aph_yield IS NOT NULL;
