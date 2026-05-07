-- Add is_verified column to product_comments table for admin verification
ALTER TABLE public.product_comments 
ADD COLUMN IF NOT EXISTS is_verified boolean NOT NULL DEFAULT false;

-- Add comment to describe the column
COMMENT ON COLUMN public.product_comments.is_verified 
IS 'Admin verification status - manually verified reviews';

-- Create index for better query performance
CREATE INDEX IF NOT EXISTS idx_product_comments_is_verified 
ON public.product_comments(is_verified);

-- Optional: Update RLS policy to allow admins to update the verification status
DROP POLICY IF EXISTS "reviews admin verify" ON public.product_comments;
CREATE POLICY "reviews admin verify" 
ON public.product_comments 
FOR UPDATE 
USING (public.current_role() IN ('admin')) 
WITH CHECK (public.current_role() IN ('admin'));
