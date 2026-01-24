-- ============================================================================
-- Fix Script: Drop existing policies before re-creating
-- Run this FIRST if you get "policy already exists" errors
-- ============================================================================

-- Drop fert_products policies
DROP POLICY IF EXISTS "Allow authenticated read fert_products" ON fert_products;
DROP POLICY IF EXISTS "Allow authenticated insert fert_products" ON fert_products;
DROP POLICY IF EXISTS "Allow authenticated update fert_products" ON fert_products;
DROP POLICY IF EXISTS "Allow authenticated delete fert_products" ON fert_products;

-- Drop fert_prepaid policies
DROP POLICY IF EXISTS "Allow authenticated read fert_prepaid" ON fert_prepaid;
DROP POLICY IF EXISTS "Allow authenticated insert fert_prepaid" ON fert_prepaid;
DROP POLICY IF EXISTS "Allow authenticated update fert_prepaid" ON fert_prepaid;
DROP POLICY IF EXISTS "Allow authenticated delete fert_prepaid" ON fert_prepaid;

-- Drop fert_plans policies
DROP POLICY IF EXISTS "Allow authenticated read fert_plans" ON fert_plans;
DROP POLICY IF EXISTS "Allow authenticated insert fert_plans" ON fert_plans;
DROP POLICY IF EXISTS "Allow authenticated update fert_plans" ON fert_plans;
DROP POLICY IF EXISTS "Allow authenticated delete fert_plans" ON fert_plans;

-- Drop fert_plan_products policies
DROP POLICY IF EXISTS "Allow authenticated read fert_plan_products" ON fert_plan_products;
DROP POLICY IF EXISTS "Allow authenticated insert fert_plan_products" ON fert_plan_products;
DROP POLICY IF EXISTS "Allow authenticated update fert_plan_products" ON fert_plan_products;
DROP POLICY IF EXISTS "Allow authenticated delete fert_plan_products" ON fert_plan_products;

-- Drop fert_applications policies
DROP POLICY IF EXISTS "Allow authenticated read fert_applications" ON fert_applications;
DROP POLICY IF EXISTS "Allow authenticated insert fert_applications" ON fert_applications;
DROP POLICY IF EXISTS "Allow authenticated update fert_applications" ON fert_applications;
DROP POLICY IF EXISTS "Allow authenticated delete fert_applications" ON fert_applications;

-- Drop fert_application_products policies
DROP POLICY IF EXISTS "Allow authenticated read fert_application_products" ON fert_application_products;
DROP POLICY IF EXISTS "Allow authenticated insert fert_application_products" ON fert_application_products;
DROP POLICY IF EXISTS "Allow authenticated update fert_application_products" ON fert_application_products;
DROP POLICY IF EXISTS "Allow authenticated delete fert_application_products" ON fert_application_products;

-- Drop fert_split_imports policies
DROP POLICY IF EXISTS "Allow authenticated read fert_split_imports" ON fert_split_imports;
DROP POLICY IF EXISTS "Allow authenticated insert fert_split_imports" ON fert_split_imports;
DROP POLICY IF EXISTS "Allow authenticated update fert_split_imports" ON fert_split_imports;
DROP POLICY IF EXISTS "Allow authenticated delete fert_split_imports" ON fert_split_imports;

-- Drop fert_split_costs policies
DROP POLICY IF EXISTS "Allow authenticated read fert_split_costs" ON fert_split_costs;
DROP POLICY IF EXISTS "Allow authenticated insert fert_split_costs" ON fert_split_costs;
DROP POLICY IF EXISTS "Allow authenticated update fert_split_costs" ON fert_split_costs;
DROP POLICY IF EXISTS "Allow authenticated delete fert_split_costs" ON fert_split_costs;

-- Drop be_overhead_categories policies
DROP POLICY IF EXISTS "Allow authenticated read be_overhead_categories" ON be_overhead_categories;
DROP POLICY IF EXISTS "Allow authenticated insert be_overhead_categories" ON be_overhead_categories;
DROP POLICY IF EXISTS "Allow authenticated update be_overhead_categories" ON be_overhead_categories;
DROP POLICY IF EXISTS "Allow authenticated delete be_overhead_categories" ON be_overhead_categories;

-- Drop be_overhead_expenses policies
DROP POLICY IF EXISTS "Allow authenticated read be_overhead_expenses" ON be_overhead_expenses;
DROP POLICY IF EXISTS "Allow authenticated insert be_overhead_expenses" ON be_overhead_expenses;
DROP POLICY IF EXISTS "Allow authenticated update be_overhead_expenses" ON be_overhead_expenses;
DROP POLICY IF EXISTS "Allow authenticated delete be_overhead_expenses" ON be_overhead_expenses;

-- Drop be_overhead_allocations policies
DROP POLICY IF EXISTS "Allow authenticated read be_overhead_allocations" ON be_overhead_allocations;
DROP POLICY IF EXISTS "Allow authenticated insert be_overhead_allocations" ON be_overhead_allocations;
DROP POLICY IF EXISTS "Allow authenticated update be_overhead_allocations" ON be_overhead_allocations;
DROP POLICY IF EXISTS "Allow authenticated delete be_overhead_allocations" ON be_overhead_allocations;

-- Drop be_seed_costs policies
DROP POLICY IF EXISTS "Allow authenticated read be_seed_costs" ON be_seed_costs;
DROP POLICY IF EXISTS "Allow authenticated insert be_seed_costs" ON be_seed_costs;
DROP POLICY IF EXISTS "Allow authenticated update be_seed_costs" ON be_seed_costs;
DROP POLICY IF EXISTS "Allow authenticated delete be_seed_costs" ON be_seed_costs;

-- Drop be_land_rent policies
DROP POLICY IF EXISTS "Allow authenticated read be_land_rent" ON be_land_rent;
DROP POLICY IF EXISTS "Allow authenticated insert be_land_rent" ON be_land_rent;
DROP POLICY IF EXISTS "Allow authenticated update be_land_rent" ON be_land_rent;
DROP POLICY IF EXISTS "Allow authenticated delete be_land_rent" ON be_land_rent;

-- Drop be_herbicide_plans policies
DROP POLICY IF EXISTS "Allow authenticated read be_herbicide_plans" ON be_herbicide_plans;
DROP POLICY IF EXISTS "Allow authenticated insert be_herbicide_plans" ON be_herbicide_plans;
DROP POLICY IF EXISTS "Allow authenticated update be_herbicide_plans" ON be_herbicide_plans;
DROP POLICY IF EXISTS "Allow authenticated delete be_herbicide_plans" ON be_herbicide_plans;

-- Drop be_field_crop_plans policies
DROP POLICY IF EXISTS "Allow authenticated read be_field_crop_plans" ON be_field_crop_plans;
DROP POLICY IF EXISTS "Allow authenticated insert be_field_crop_plans" ON be_field_crop_plans;
DROP POLICY IF EXISTS "Allow authenticated update be_field_crop_plans" ON be_field_crop_plans;
DROP POLICY IF EXISTS "Allow authenticated delete be_field_crop_plans" ON be_field_crop_plans;

-- Drop be_field_herbicide_passes policies
DROP POLICY IF EXISTS "Allow authenticated read be_field_herbicide_passes" ON be_field_herbicide_passes;
DROP POLICY IF EXISTS "Allow authenticated insert be_field_herbicide_passes" ON be_field_herbicide_passes;
DROP POLICY IF EXISTS "Allow authenticated update be_field_herbicide_passes" ON be_field_herbicide_passes;
DROP POLICY IF EXISTS "Allow authenticated delete be_field_herbicide_passes" ON be_field_herbicide_passes;

-- Drop be_field_breakeven policies
DROP POLICY IF EXISTS "Allow authenticated read be_field_breakeven" ON be_field_breakeven;
DROP POLICY IF EXISTS "Allow authenticated insert be_field_breakeven" ON be_field_breakeven;
DROP POLICY IF EXISTS "Allow authenticated update be_field_breakeven" ON be_field_breakeven;
DROP POLICY IF EXISTS "Allow authenticated delete be_field_breakeven" ON be_field_breakeven;

-- ============================================================================
-- Now re-run the main migration: farm_management_suite.sql
-- ============================================================================
