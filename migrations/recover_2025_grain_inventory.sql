-- Restore 2025 grain inventory
-- Copy and paste into Supabase SQL Editor and run once

ALTER TABLE grain_inventory ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMPTZ DEFAULT NULL;

UPDATE grain_inventory
SET deleted_at = NULL
WHERE crop_year = 2025
  AND deleted_at IS NOT NULL;
