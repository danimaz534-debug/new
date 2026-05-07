-- ==========================================
-- COMPLETE FIX FOR REVIEWS PAGE
-- ==========================================

-- 1. Add missing columns (run this first)
ALTER TABLE public.product_comments 
ADD COLUMN IF NOT EXISTS is_verified_purchase boolean NOT NULL DEFAULT false;

ALTER TABLE public.product_comments 
ADD COLUMN IF NOT EXISTS is_verified boolean NOT NULL DEFAULT false;

-- 2. Fix RLS policies to allow updates
DROP POLICY IF EXISTS "reviews admin verify" ON public.product_comments;
CREATE POLICY "reviews admin verify" 
ON public.product_comments 
FOR UPDATE 
USING (public.current_role() = 'admin')
WITH CHECK (public.current_role() = 'admin');

-- 3. Allow all authenticated users to update their own reviews
DROP POLICY IF EXISTS "users update own reviews" ON public.product_comments;
CREATE POLICY "users update own reviews" 
ON public.product_comments 
FOR UPDATE 
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

-- 4. Verify columns exist
SELECT column_name, data_type, column_default
FROM information_schema.columns
WHERE table_name = 'product_comments' 
AND column_name LIKE '%verified%';
