-- Migration: Enable Row Level Security (Grain-Specific Tables Only)
-- Run this in Supabase SQL Editor
-- This ensures only authenticated users can access grain trading data
--
-- NOTE: Shared tables (farms, fields, storage_locations, inventory,
-- inventory_transactions) are NOT included here because they are used
-- by spray-suite apps that don't have authentication yet.

-- ============================================================================
-- ENABLE RLS ON GRAIN-SPECIFIC TABLES ONLY
-- ============================================================================

ALTER TABLE commodities ENABLE ROW LEVEL SECURITY;
ALTER TABLE buyers ENABLE ROW LEVEL SECURITY;
ALTER TABLE contracts ENABLE ROW LEVEL SECURITY;
ALTER TABLE field_crop_years ENABLE ROW LEVEL SECURITY;
ALTER TABLE grain_field_settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE insurance_settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE location_basis ENABLE ROW LEVEL SECURITY;
ALTER TABLE market_prices ENABLE ROW LEVEL SECURITY;
ALTER TABLE barchart_technicals ENABLE ROW LEVEL SECURITY;

-- ============================================================================
-- CREATE POLICIES FOR AUTHENTICATED USERS
-- For now, any authenticated user can read/write all data
-- Later we can add organization-based restrictions
-- ============================================================================

-- Commodities (read-only for now, admin manages these)
CREATE POLICY "Authenticated users can read commodities"
  ON commodities FOR SELECT
  TO authenticated
  USING (true);

-- Buyers
CREATE POLICY "Authenticated users can manage buyers"
  ON buyers FOR ALL
  TO authenticated
  USING (true)
  WITH CHECK (true);

-- Contracts
CREATE POLICY "Authenticated users can manage contracts"
  ON contracts FOR ALL
  TO authenticated
  USING (true)
  WITH CHECK (true);

-- Field Crop Years
CREATE POLICY "Authenticated users can manage field_crop_years"
  ON field_crop_years FOR ALL
  TO authenticated
  USING (true)
  WITH CHECK (true);

-- Grain Field Settings
CREATE POLICY "Authenticated users can manage grain_field_settings"
  ON grain_field_settings FOR ALL
  TO authenticated
  USING (true)
  WITH CHECK (true);

-- Insurance Settings
CREATE POLICY "Authenticated users can manage insurance_settings"
  ON insurance_settings FOR ALL
  TO authenticated
  USING (true)
  WITH CHECK (true);

-- Location Basis
CREATE POLICY "Authenticated users can manage location_basis"
  ON location_basis FOR ALL
  TO authenticated
  USING (true)
  WITH CHECK (true);

-- Market Prices
CREATE POLICY "Authenticated users can manage market_prices"
  ON market_prices FOR ALL
  TO authenticated
  USING (true)
  WITH CHECK (true);

-- Barchart Technicals (read-only, populated by external script)
CREATE POLICY "Authenticated users can read barchart_technicals"
  ON barchart_technicals FOR SELECT
  TO authenticated
  USING (true);

-- Allow service role to manage barchart data (for Google Apps Script)
CREATE POLICY "Service role can manage barchart_technicals"
  ON barchart_technicals FOR ALL
  TO service_role
  USING (true)
  WITH CHECK (true);
