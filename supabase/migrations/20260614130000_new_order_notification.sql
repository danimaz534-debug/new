-- Trigger to create notification when new order is placed
CREATE OR REPLACE FUNCTION public.handle_new_order()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.notifications (user_id, title, body, type, is_read)
  VALUES (
    NEW.user_id,
    'New Order Placed',
    'Your order ' || COALESCE(NEW.tracking_code, NEW.id::text) || ' has been placed successfully',
    'new_order',
    false
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS tr_new_order ON public.orders;
CREATE TRIGGER tr_new_order
  AFTER INSERT ON public.orders
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_new_order();