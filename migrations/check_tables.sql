-- Check if tables exist in any schema
SELECT
  table_schema,
  table_name,
  table_type
FROM information_schema.tables
WHERE table_name LIKE 'be_misc_income%'
ORDER BY table_schema, table_name;

-- Check all tables in public schema
SELECT tablename
FROM pg_tables
WHERE schemaname = 'public'
ORDER BY tablename;
