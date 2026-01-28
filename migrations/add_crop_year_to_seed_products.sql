-- ============================================================================
-- Add crop_year to be_seed_products table
-- Allows tracking different seed products/prices by year
-- Run this in Supabase SQL Editor
-- ============================================================================

-- Add crop_year column to be_seed_products
ALTER TABLE be_seed_products
ADD COLUMN IF NOT EXISTS crop_year INTEGER NOT NULL DEFAULT 2026;

-- Create index for performance
CREATE INDEX IF NOT EXISTS idx_be_seed_products_crop_year ON be_seed_products(crop_year);

-- Add comment
COMMENT ON COLUMN be_seed_products.crop_year IS 'Crop year for this seed product entry. Allows tracking different prices/products by year.';

-- ============================================================================
-- VERIFICATION
-- ============================================================================
-- Verify the column was added:
-- SELECT column_name, data_type, column_default
-- FROM information_schema.columns
-- WHERE table_name = 'be_seed_products' AND column_name = 'crop_year';

-- Check existing data:
-- SELECT id, brand, hybrid, crop_year FROM be_seed_products LIMIT 5;
