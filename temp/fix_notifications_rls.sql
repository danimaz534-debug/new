-- Fix RLS policy for notifications update to allow admin/sales to mark any notification as read
DROP POLICY IF EXISTS "users update notifications" ON public.notifications;

CREATE POLICY "users update notifications" ON public.notifications 
FOR UPDATE 
USING (user_id = auth.uid() OR public.current_role() IN ('admin', 'sales')) 
WITH CHECK (user_id = auth.uid() OR public.current_role() IN ('admin', 'sales'));

-- Also allow admin/sales to view all notifications (not just their own)
DROP POLICY IF EXISTS "users read own notifications" ON public.notifications;
CREATE POLICY "users read own notifications" ON public.notifications 
FOR SELECT 
USING (user_id = auth.uid() OR public.current_role() IN ('admin', 'sales'));
