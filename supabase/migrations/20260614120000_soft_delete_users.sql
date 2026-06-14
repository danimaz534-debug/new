-- Soft delete users migration
-- Add deleted_at column to profiles for soft delete

ALTER TABLE public.profiles
  ADD COLUMN IF NOT EXISTS deleted_at timestamptz;

-- Add index for filtering non-deleted users
CREATE INDEX IF NOT EXISTS idx_profiles_deleted_at ON public.profiles(deleted_at) WHERE deleted_at IS NULL;

-- Create a view for active (non-deleted) users
CREATE OR REPLACE VIEW public.active_profiles AS
SELECT * FROM public.profiles
WHERE deleted_at IS NULL;

-- Grant access to the view
GRANT SELECT ON public.active_profiles TO anon, authenticated, service_role;

-- Function to permanently delete users older than 7 days
CREATE OR REPLACE FUNCTION public.cleanup_deleted_users()
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  DELETE FROM public.profiles
  WHERE deleted_at IS NOT NULL
    AND deleted_at < now() - INTERVAL '7 days';
END;
$$;

-- Grant execute to service role
GRANT EXECUTE ON FUNCTION public.cleanup_deleted_users() TO service_role;