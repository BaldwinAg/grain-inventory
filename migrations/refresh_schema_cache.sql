-- Refresh Supabase Schema Cache
-- Run this after creating new tables if they show 404 errors

-- This forces PostgREST to reload the schema
NOTIFY pgrst, 'reload schema';

-- Alternative: You can also restart the PostgREST server from Supabase dashboard
-- Settings > Database > Connection pooling > Restart

-- Verify tables exist
SELECT schemaname, tablename
FROM pg_tables
WHERE tablename LIKE 'be_misc_income%'
ORDER BY tablename;
