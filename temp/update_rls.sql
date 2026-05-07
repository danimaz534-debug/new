DROP POLICY IF EXISTS "Admins can view all favorites" ON public.favorites;
CREATE POLICY "Admins can view all favorites" ON public.favorites
  FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.profiles
      WHERE profiles.id = auth.uid()
      AND profiles.role IN ('admin', 'sales', 'marketing', 'superuser')
    )
  );
