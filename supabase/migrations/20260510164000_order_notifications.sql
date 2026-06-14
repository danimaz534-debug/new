-- Trigger to create notifications when order status is updated
CREATE OR REPLACE FUNCTION public.handle_order_status_update()
RETURNS TRIGGER AS $$
BEGIN
  -- We only want to notify when the status actually changes
  IF (OLD.status IS DISTINCT FROM NEW.status) THEN
    INSERT INTO public.notifications (user_id, title, body, type, is_read)
    VALUES (
      NEW.user_id,
      CASE 
        WHEN NEW.status = 'Preparing' THEN 'Order Preparing'
        WHEN NEW.status = 'Shipped' THEN 'Order Shipped'
        WHEN NEW.status = 'On the way' THEN 'Order on the Way'
        WHEN NEW.status = 'Delivered' THEN 'Order Delivered'
        WHEN NEW.status = 'Cancelled' THEN 'Order Cancelled'
        ELSE 'Order Update'
      END,
      'Your order ' || COALESCE(NEW.tracking_code, NEW.id::text) || ' is now ' || NEW.status,
      'order',
      false
    );
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS tr_order_status_update ON public.orders;
CREATE TRIGGER tr_order_status_update
  AFTER UPDATE ON public.orders
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_order_status_update();
