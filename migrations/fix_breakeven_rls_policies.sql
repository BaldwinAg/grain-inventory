-- ============================================================================
-- FIX BREAKEVEN RLS POLICIES FOR AUTHENTICATED USERS
-- Run this in Supabase SQL Editor
-- ============================================================================

-- This script adds SELECT, INSERT, UPDATE, DELETE policies for authenticated users
-- on all breakeven tables. Many tables only had 'anon' policies.

-- ============================================================================
-- OVERHEAD TABLES
-- ============================================================================

-- be_overhead_categories (already fixed, but ensuring completeness)
DO $$ BEGIN
  CREATE POLICY "Allow authenticated read be_overhead_categories" ON be_overhead_categories FOR SELECT TO authenticated USING (true);
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE POLICY "Allow authenticated insert be_overhead_categories" ON be_overhead_categories FOR INSERT TO authenticated WITH CHECK (true);
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE POLICY "Allow authenticated update be_overhead_categories" ON be_overhead_categories FOR UPDATE TO authenticated USING (true);
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE POLICY "Allow authenticated delete be_overhead_categories" ON be_overhead_categories FOR DELETE TO authenticated USING (true);
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- be_overhead_expenses (already fixed, ensuring completeness)
DO $$ BEGIN
  CREATE POLICY "Allow authenticated read be_overhead_expenses" ON be_overhead_expenses FOR SELECT TO authenticated USING (true);
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE POLICY "Allow authenticated insert be_overhead_expenses" ON be_overhead_expenses FOR INSERT TO authenticated WITH CHECK (true);
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE POLICY "Allow authenticated update be_overhead_expenses" ON be_overhead_expenses FOR UPDATE TO authenticated USING (true);
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE POLICY "Allow authenticated delete be_overhead_expenses" ON be_overhead_expenses FOR DELETE TO authenticated USING (true);
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- be_overhead_allocations
DO $$ BEGIN
  CREATE POLICY "Allow authenticated read be_overhead_allocations" ON be_overhead_allocations FOR SELECT TO authenticated USING (true);
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE POLICY "Allow authenticated insert be_overhead_allocations" ON be_overhead_allocations FOR INSERT TO authenticated WITH CHECK (true);
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE POLICY "Allow authenticated update be_overhead_allocations" ON be_overhead_allocations FOR UPDATE TO authenticated USING (true);
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE POLICY "Allow authenticated delete be_overhead_allocations" ON be_overhead_allocations FOR DELETE TO authenticated USING (true);
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- ============================================================================
-- SEED & LAND RENT TABLES
-- ============================================================================

-- be_seed_costs
DO $$ BEGIN
  CREATE POLICY "Allow authenticated read be_seed_costs" ON be_seed_costs FOR SELECT TO authenticated USING (true);
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE POLICY "Allow authenticated insert be_seed_costs" ON be_seed_costs FOR INSERT TO authenticated WITH CHECK (true);
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE POLICY "Allow authenticated update be_seed_costs" ON be_seed_costs FOR UPDATE TO authenticated USING (true);
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE POLICY "Allow authenticated delete be_seed_costs" ON be_seed_costs FOR DELETE TO authenticated USING (true);
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- be_land_rent
DO $$ BEGIN
  CREATE POLICY "Allow authenticated read be_land_rent" ON be_land_rent FOR SELECT TO authenticated USING (true);
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE POLICY "Allow authenticated insert be_land_rent" ON be_land_rent FOR INSERT TO authenticated WITH CHECK (true);
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE POLICY "Allow authenticated update be_land_rent" ON be_land_rent FOR UPDATE TO authenticated USING (true);
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE POLICY "Allow authenticated delete be_land_rent" ON be_land_rent FOR DELETE TO authenticated USING (true);
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- ============================================================================
-- HERBICIDE PLAN TABLES
-- ============================================================================

-- be_herbicide_plans
DO $$ BEGIN
  CREATE POLICY "Allow authenticated read be_herbicide_plans" ON be_herbicide_plans FOR SELECT TO authenticated USING (true);
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE POLICY "Allow authenticated insert be_herbicide_plans" ON be_herbicide_plans FOR INSERT TO authenticated WITH CHECK (true);
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE POLICY "Allow authenticated update be_herbicide_plans" ON be_herbicide_plans FOR UPDATE TO authenticated USING (true);
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE POLICY "Allow authenticated delete be_herbicide_plans" ON be_herbicide_plans FOR DELETE TO authenticated USING (true);
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- be_field_crop_plans
DO $$ BEGIN
  CREATE POLICY "Allow authenticated read be_field_crop_plans" ON be_field_crop_plans FOR SELECT TO authenticated USING (true);
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE POLICY "Allow authenticated insert be_field_crop_plans" ON be_field_crop_plans FOR INSERT TO authenticated WITH CHECK (true);
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE POLICY "Allow authenticated update be_field_crop_plans" ON be_field_crop_plans FOR UPDATE TO authenticated USING (true);
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE POLICY "Allow authenticated delete be_field_crop_plans" ON be_field_crop_plans FOR DELETE TO authenticated USING (true);
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- be_field_herbicide_passes
DO $$ BEGIN
  CREATE POLICY "Allow authenticated read be_field_herbicide_passes" ON be_field_herbicide_passes FOR SELECT TO authenticated USING (true);
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE POLICY "Allow authenticated insert be_field_herbicide_passes" ON be_field_herbicide_passes FOR INSERT TO authenticated WITH CHECK (true);
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE POLICY "Allow authenticated update be_field_herbicide_passes" ON be_field_herbicide_passes FOR UPDATE TO authenticated USING (true);
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE POLICY "Allow authenticated delete be_field_herbicide_passes" ON be_field_herbicide_passes FOR DELETE TO authenticated USING (true);
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- be_field_breakeven
DO $$ BEGIN
  CREATE POLICY "Allow authenticated read be_field_breakeven" ON be_field_breakeven FOR SELECT TO authenticated USING (true);
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE POLICY "Allow authenticated insert be_field_breakeven" ON be_field_breakeven FOR INSERT TO authenticated WITH CHECK (true);
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE POLICY "Allow authenticated update be_field_breakeven" ON be_field_breakeven FOR UPDATE TO authenticated USING (true);
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE POLICY "Allow authenticated delete be_field_breakeven" ON be_field_breakeven FOR DELETE TO authenticated USING (true);
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- ============================================================================
-- CROP PLAN TABLES (Phase 2)
-- ============================================================================

-- be_crop_plans
DO $$ BEGIN
  CREATE POLICY "Allow authenticated read be_crop_plans" ON be_crop_plans FOR SELECT TO authenticated USING (true);
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE POLICY "Allow authenticated insert be_crop_plans" ON be_crop_plans FOR INSERT TO authenticated WITH CHECK (true);
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE POLICY "Allow authenticated update be_crop_plans" ON be_crop_plans FOR UPDATE TO authenticated USING (true);
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE POLICY "Allow authenticated delete be_crop_plans" ON be_crop_plans FOR DELETE TO authenticated USING (true);
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- be_crop_plan_seed
DO $$ BEGIN
  CREATE POLICY "Allow authenticated read be_crop_plan_seed" ON be_crop_plan_seed FOR SELECT TO authenticated USING (true);
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE POLICY "Allow authenticated insert be_crop_plan_seed" ON be_crop_plan_seed FOR INSERT TO authenticated WITH CHECK (true);
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE POLICY "Allow authenticated update be_crop_plan_seed" ON be_crop_plan_seed FOR UPDATE TO authenticated USING (true);
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE POLICY "Allow authenticated delete be_crop_plan_seed" ON be_crop_plan_seed FOR DELETE TO authenticated USING (true);
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- be_crop_plan_custom_costs
DO $$ BEGIN
  CREATE POLICY "Allow authenticated read be_crop_plan_custom_costs" ON be_crop_plan_custom_costs FOR SELECT TO authenticated USING (true);
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE POLICY "Allow authenticated insert be_crop_plan_custom_costs" ON be_crop_plan_custom_costs FOR INSERT TO authenticated WITH CHECK (true);
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE POLICY "Allow authenticated update be_crop_plan_custom_costs" ON be_crop_plan_custom_costs FOR UPDATE TO authenticated USING (true);
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE POLICY "Allow authenticated delete be_crop_plan_custom_costs" ON be_crop_plan_custom_costs FOR DELETE TO authenticated USING (true);
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- be_crop_plan_fertilizer
DO $$ BEGIN
  CREATE POLICY "Allow authenticated read be_crop_plan_fertilizer" ON be_crop_plan_fertilizer FOR SELECT TO authenticated USING (true);
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE POLICY "Allow authenticated insert be_crop_plan_fertilizer" ON be_crop_plan_fertilizer FOR INSERT TO authenticated WITH CHECK (true);
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE POLICY "Allow authenticated update be_crop_plan_fertilizer" ON be_crop_plan_fertilizer FOR UPDATE TO authenticated USING (true);
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE POLICY "Allow authenticated delete be_crop_plan_fertilizer" ON be_crop_plan_fertilizer FOR DELETE TO authenticated USING (true);
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- be_crop_plan_fertilizer_products
DO $$ BEGIN
  CREATE POLICY "Allow authenticated read be_crop_plan_fertilizer_products" ON be_crop_plan_fertilizer_products FOR SELECT TO authenticated USING (true);
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE POLICY "Allow authenticated insert be_crop_plan_fertilizer_products" ON be_crop_plan_fertilizer_products FOR INSERT TO authenticated WITH CHECK (true);
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE POLICY "Allow authenticated update be_crop_plan_fertilizer_products" ON be_crop_plan_fertilizer_products FOR UPDATE TO authenticated USING (true);
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE POLICY "Allow authenticated delete be_crop_plan_fertilizer_products" ON be_crop_plan_fertilizer_products FOR DELETE TO authenticated USING (true);
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- be_crop_plan_chemicals
DO $$ BEGIN
  CREATE POLICY "Allow authenticated read be_crop_plan_chemicals" ON be_crop_plan_chemicals FOR SELECT TO authenticated USING (true);
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE POLICY "Allow authenticated insert be_crop_plan_chemicals" ON be_crop_plan_chemicals FOR INSERT TO authenticated WITH CHECK (true);
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE POLICY "Allow authenticated update be_crop_plan_chemicals" ON be_crop_plan_chemicals FOR UPDATE TO authenticated USING (true);
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE POLICY "Allow authenticated delete be_crop_plan_chemicals" ON be_crop_plan_chemicals FOR DELETE TO authenticated USING (true);
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- be_crop_plan_chemical_products
DO $$ BEGIN
  CREATE POLICY "Allow authenticated read be_crop_plan_chemical_products" ON be_crop_plan_chemical_products FOR SELECT TO authenticated USING (true);
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE POLICY "Allow authenticated insert be_crop_plan_chemical_products" ON be_crop_plan_chemical_products FOR INSERT TO authenticated WITH CHECK (true);
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE POLICY "Allow authenticated update be_crop_plan_chemical_products" ON be_crop_plan_chemical_products FOR UPDATE TO authenticated USING (true);
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE POLICY "Allow authenticated delete be_crop_plan_chemical_products" ON be_crop_plan_chemical_products FOR DELETE TO authenticated USING (true);
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- ============================================================================
-- FIELD ASSIGNMENT TABLES (Phase 4)
-- ============================================================================

-- be_field_plan_assignments
DO $$ BEGIN
  CREATE POLICY "Allow authenticated read be_field_plan_assignments" ON be_field_plan_assignments FOR SELECT TO authenticated USING (true);
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE POLICY "Allow authenticated insert be_field_plan_assignments" ON be_field_plan_assignments FOR INSERT TO authenticated WITH CHECK (true);
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE POLICY "Allow authenticated update be_field_plan_assignments" ON be_field_plan_assignments FOR UPDATE TO authenticated USING (true);
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE POLICY "Allow authenticated delete be_field_plan_assignments" ON be_field_plan_assignments FOR DELETE TO authenticated USING (true);
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- be_field_custom_cost_overrides
DO $$ BEGIN
  CREATE POLICY "Allow authenticated read be_field_custom_cost_overrides" ON be_field_custom_cost_overrides FOR SELECT TO authenticated USING (true);
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE POLICY "Allow authenticated insert be_field_custom_cost_overrides" ON be_field_custom_cost_overrides FOR INSERT TO authenticated WITH CHECK (true);
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE POLICY "Allow authenticated update be_field_custom_cost_overrides" ON be_field_custom_cost_overrides FOR UPDATE TO authenticated USING (true);
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE POLICY "Allow authenticated delete be_field_custom_cost_overrides" ON be_field_custom_cost_overrides FOR DELETE TO authenticated USING (true);
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- ============================================================================
-- MISC INCOME TABLES (from breakeven_redesign.sql)
-- Note: These tables may not exist yet if migration wasn't run
-- ============================================================================

-- be_misc_income_categories
DO $$ BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'be_misc_income_categories') THEN
    EXECUTE 'CREATE POLICY "Allow authenticated read be_misc_income_categories" ON be_misc_income_categories FOR SELECT TO authenticated USING (true)';
  END IF;
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'be_misc_income_categories') THEN
    EXECUTE 'CREATE POLICY "Allow authenticated insert be_misc_income_categories" ON be_misc_income_categories FOR INSERT TO authenticated WITH CHECK (true)';
  END IF;
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'be_misc_income_categories') THEN
    EXECUTE 'CREATE POLICY "Allow authenticated update be_misc_income_categories" ON be_misc_income_categories FOR UPDATE TO authenticated USING (true)';
  END IF;
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'be_misc_income_categories') THEN
    EXECUTE 'CREATE POLICY "Allow authenticated delete be_misc_income_categories" ON be_misc_income_categories FOR DELETE TO authenticated USING (true)';
  END IF;
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- be_misc_income
DO $$ BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'be_misc_income') THEN
    EXECUTE 'CREATE POLICY "Allow authenticated read be_misc_income" ON be_misc_income FOR SELECT TO authenticated USING (true)';
  END IF;
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'be_misc_income') THEN
    EXECUTE 'CREATE POLICY "Allow authenticated insert be_misc_income" ON be_misc_income FOR INSERT TO authenticated WITH CHECK (true)';
  END IF;
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'be_misc_income') THEN
    EXECUTE 'CREATE POLICY "Allow authenticated update be_misc_income" ON be_misc_income FOR UPDATE TO authenticated USING (true)';
  END IF;
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'be_misc_income') THEN
    EXECUTE 'CREATE POLICY "Allow authenticated delete be_misc_income" ON be_misc_income FOR DELETE TO authenticated USING (true)';
  END IF;
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- be_misc_income_allocations
DO $$ BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'be_misc_income_allocations') THEN
    EXECUTE 'CREATE POLICY "Allow authenticated read be_misc_income_allocations" ON be_misc_income_allocations FOR SELECT TO authenticated USING (true)';
  END IF;
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'be_misc_income_allocations') THEN
    EXECUTE 'CREATE POLICY "Allow authenticated insert be_misc_income_allocations" ON be_misc_income_allocations FOR INSERT TO authenticated WITH CHECK (true)';
  END IF;
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'be_misc_income_allocations') THEN
    EXECUTE 'CREATE POLICY "Allow authenticated update be_misc_income_allocations" ON be_misc_income_allocations FOR UPDATE TO authenticated USING (true)';
  END IF;
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'be_misc_income_allocations') THEN
    EXECUTE 'CREATE POLICY "Allow authenticated delete be_misc_income_allocations" ON be_misc_income_allocations FOR DELETE TO authenticated USING (true)';
  END IF;
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- be_actual_costs
DO $$ BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'be_actual_costs') THEN
    EXECUTE 'CREATE POLICY "Allow authenticated read be_actual_costs" ON be_actual_costs FOR SELECT TO authenticated USING (true)';
  END IF;
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'be_actual_costs') THEN
    EXECUTE 'CREATE POLICY "Allow authenticated insert be_actual_costs" ON be_actual_costs FOR INSERT TO authenticated WITH CHECK (true)';
  END IF;
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'be_actual_costs') THEN
    EXECUTE 'CREATE POLICY "Allow authenticated update be_actual_costs" ON be_actual_costs FOR UPDATE TO authenticated USING (true)';
  END IF;
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'be_actual_costs') THEN
    EXECUTE 'CREATE POLICY "Allow authenticated delete be_actual_costs" ON be_actual_costs FOR DELETE TO authenticated USING (true)';
  END IF;
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- ============================================================================
-- SPRAY-SUITE TABLES (tank_mixes, products)
-- These are used by Breakeven for chemical cost planning
-- ============================================================================

-- tank_mixes
DO $$ BEGIN
  CREATE POLICY "Allow authenticated read tank_mixes" ON tank_mixes FOR SELECT TO authenticated USING (true);
EXCEPTION WHEN duplicate_object THEN NULL; WHEN undefined_table THEN NULL; END $$;

DO $$ BEGIN
  CREATE POLICY "Allow anon read tank_mixes" ON tank_mixes FOR SELECT TO anon USING (true);
EXCEPTION WHEN duplicate_object THEN NULL; WHEN undefined_table THEN NULL; END $$;

-- tank_mix_products
DO $$ BEGIN
  CREATE POLICY "Allow authenticated read tank_mix_products" ON tank_mix_products FOR SELECT TO authenticated USING (true);
EXCEPTION WHEN duplicate_object THEN NULL; WHEN undefined_table THEN NULL; END $$;

DO $$ BEGIN
  CREATE POLICY "Allow anon read tank_mix_products" ON tank_mix_products FOR SELECT TO anon USING (true);
EXCEPTION WHEN duplicate_object THEN NULL; WHEN undefined_table THEN NULL; END $$;

-- products (spray-suite)
DO $$ BEGIN
  CREATE POLICY "Allow authenticated read products" ON products FOR SELECT TO authenticated USING (true);
EXCEPTION WHEN duplicate_object THEN NULL; WHEN undefined_table THEN NULL; END $$;

DO $$ BEGIN
  CREATE POLICY "Allow anon read products" ON products FOR SELECT TO anon USING (true);
EXCEPTION WHEN duplicate_object THEN NULL; WHEN undefined_table THEN NULL; END $$;

-- ============================================================================
-- VERIFICATION
-- ============================================================================

-- List all policies on breakeven tables
SELECT schemaname, tablename, policyname, permissive, roles, cmd
FROM pg_policies
WHERE tablename LIKE 'be_%' OR tablename IN ('tank_mixes', 'tank_mix_products', 'products')
ORDER BY tablename, cmd;
