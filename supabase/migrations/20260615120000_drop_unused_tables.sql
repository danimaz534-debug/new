-- Drop unused tables: wholesale_codes and watch_history
-- These tables are not used in the application code

-- Drop watch_history table (no foreign key dependencies)
DROP TABLE IF EXISTS public.watch_history CASCADE;

-- Drop wholesale_codes table (has foreign key references from profiles)
-- First drop the foreign key constraints, then the table
ALTER TABLE public.wholesale_codes DROP CONSTRAINT IF EXISTS wholesale_codes_created_by_fkey;
ALTER TABLE public.wholesale_codes DROP CONSTRAINT IF EXISTS wholesale_codes_redeemed_by_fkey;
DROP TABLE IF EXISTS public.wholesale_codes CASCADE;