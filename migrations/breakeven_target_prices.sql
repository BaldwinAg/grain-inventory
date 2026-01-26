-- Target Prices for Uncontracted Bushels
-- Allows users to set expected/target prices for bushels not yet contracted
-- Used to calculate estimated profit/loss

CREATE TABLE IF NOT EXISTS be_target_prices (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  crop_year INTEGER NOT NULL,
  commodity_id UUID NOT NULL REFERENCES commodities(id),
  target_price NUMERIC(10, 4) NOT NULL CHECK (target_price > 0),
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now(),
  deleted_at TIMESTAMPTZ,
  UNIQUE(crop_year, commodity_id, deleted_at)
);

-- RLS Policies
ALTER TABLE be_target_prices ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Enable read for authenticated users" ON be_target_prices
  FOR SELECT USING (auth.role() = 'authenticated');

CREATE POLICY "Enable insert for authenticated users" ON be_target_prices
  FOR INSERT WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Enable update for authenticated users" ON be_target_prices
  FOR UPDATE USING (auth.role() = 'authenticated');

CREATE POLICY "Enable delete for authenticated users" ON be_target_prices
  FOR DELETE USING (auth.role() = 'authenticated');

-- Index for performance
CREATE INDEX idx_be_target_prices_crop_year ON be_target_prices(crop_year) WHERE deleted_at IS NULL;
CREATE INDEX idx_be_target_prices_commodity ON be_target_prices(commodity_id) WHERE deleted_at IS NULL;

COMMENT ON TABLE be_target_prices IS 'Target/expected prices for uncontracted bushels to estimate profit/loss';
COMMENT ON COLUMN be_target_prices.target_price IS 'Expected sale price per bushel for uncontracted production';
