-- ============================================
-- 1. Fix notifications RLS policies
-- ============================================

-- Drop existing policies that might be conflicting
DROP POLICY IF EXISTS "users read own notifications" ON public.notifications;
DROP POLICY IF EXISTS "users update notifications" ON public.notifications;
DROP POLICY IF EXISTS "staff insert notifications" ON public.notifications;
DROP POLICY IF EXISTS "users delete own notifications" ON public.notifications;

-- Allow users to read their own notifications OR staff to read all
CREATE POLICY "users read own notifications" 
ON public.notifications 
FOR SELECT 
USING (user_id = auth.uid() OR public.current_role() IN ('admin', 'sales'));

-- Allow users to update their own notifications OR staff to update any
CREATE POLICY "users update notifications" 
ON public.notifications 
FOR UPDATE 
USING (user_id = auth.uid() OR public.current_role() IN ('admin', 'sales'))
WITH CHECK (user_id = auth.uid() OR public.current_role() IN ('admin', 'sales'));

-- Allow staff to insert notifications
CREATE POLICY "staff insert notifications" 
ON public.notifications 
FOR INSERT 
WITH CHECK (user_id = auth.uid() OR public.current_role() IN ('admin', 'sales'));

-- Allow users to delete their own notifications OR staff to delete any
CREATE POLICY "users delete own notifications" 
ON public.notifications 
FOR DELETE 
USING (user_id = auth.uid() OR public.current_role() IN ('admin', 'sales'));

-- ============================================
-- 2. Add is_verified_purchase column if not exists
-- ============================================
ALTER TABLE public.product_comments 
ADD COLUMN IF NOT EXISTS is_verified_purchase boolean NOT NULL DEFAULT false;

COMMENT ON COLUMN public.product_comments.is_verified_purchase 
IS 'Indicates if the review is from a verified purchase';

-- ============================================
-- 3. Ensure is_verified column exists for admin verification
-- ============================================
ALTER TABLE public.product_comments 
ADD COLUMN IF NOT EXISTS is_verified boolean NOT NULL DEFAULT false;

COMMENT ON COLUMN public.product_comments.is_verified 
IS 'Admin verification status - manually verified reviews';

-- ============================================
-- 4. Update RLS for product_comments to allow admin verification
-- ============================================
DROP POLICY IF EXISTS "reviews admin verify" ON public.product_comments;
CREATE POLICY "reviews admin verify" 
ON public.product_comments 
FOR UPDATE 
USING (public.current_role() = 'admin')
WITH CHECK (public.current_role() = 'admin');
