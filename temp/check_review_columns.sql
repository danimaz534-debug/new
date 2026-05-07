-- Check if column exists (run this first in Supabase SQL Editor)
SELECT column_name, data_type, column_default
FROM information_schema.columns
WHERE table_name = 'product_comments' 
AND column_name LIKE '%verified%';

-- If no rows returned, add the columns:
ALTER TABLE public.product_comments 
ADD COLUMN IF NOT EXISTS is_verified_purchase boolean NOT NULL DEFAULT false;

ALTER TABLE public.product_comments 
ADD COLUMN IF NOT EXISTS is_verified boolean NOT NULL DEFAULT false;

-- Verify columns were added:
SELECT column_name, data_type, column_default
FROM information_schema.columns
WHERE table_name = 'product_comments' 
AND column_name LIKE '%verified%';
