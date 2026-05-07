-- AI Auto-Reply Chat System Migration

-- 1. Add AI mode tracking columns to chat_threads
ALTER TABLE public.chat_threads
  ADD COLUMN IF NOT EXISTS ai_mode_active boolean NOT NULL DEFAULT false,
  ADD COLUMN IF NOT EXISTS awaiting_admin_response boolean NOT NULL DEFAULT false,
  ADD COLUMN IF NOT EXISTS pending_ai_job_id uuid,
  ADD COLUMN IF NOT EXISTS last_user_message_at timestamptz,
  ADD COLUMN IF NOT EXISTS last_admin_message_at timestamptz,
  ADD COLUMN IF NOT EXISTS last_ai_message_at timestamptz;

-- 2. Add indexes for efficient queries
CREATE INDEX IF NOT EXISTS idx_chat_threads_user_id ON public.chat_threads(user_id);
CREATE INDEX IF NOT EXISTS idx_chat_threads_ai_mode ON public.chat_threads(ai_mode_active) WHERE ai_mode_active = true;
CREATE INDEX IF NOT EXISTS idx_chat_threads_awaiting ON public.chat_threads(awaiting_admin_response) WHERE awaiting_admin_response = true;
CREATE INDEX IF NOT EXISTS idx_chat_messages_thread_created ON public.chat_messages(thread_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_chat_messages_sender_type ON public.chat_messages(sender_type);
CREATE INDEX IF NOT EXISTS idx_chat_messages_thread_sender ON public.chat_messages(thread_id, sender_type, created_at DESC);

-- 3. Extend sender_type check constraint to include 'ai' and 'admin'
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.check_constraints
    WHERE constraint_name = 'chat_messages_sender_type_check'
  ) THEN
    ALTER TABLE public.chat_messages
      DROP CONSTRAINT chat_messages_sender_type_check;
  END IF;
END$$;

ALTER TABLE public.chat_messages
  ADD CONSTRAINT chat_messages_sender_type_check
  CHECK (sender_type IN ('user', 'sales', 'ai', 'admin'));

-- 4. Create scheduled_jobs table for delayed AI timeout checks
CREATE TABLE IF NOT EXISTS public.scheduled_jobs (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  job_type text NOT NULL,
  thread_id uuid NOT NULL REFERENCES public.chat_threads(id) ON DELETE CASCADE,
  scheduled_at timestamptz NOT NULL DEFAULT now(),
  status text NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'processing', 'completed', 'cancelled', 'failed')),
  attempts integer NOT NULL DEFAULT 0,
  max_attempts integer NOT NULL DEFAULT 3,
  error_message text,
  created_at timestamptz NOT NULL DEFAULT now(),
  processed_at timestamptz
);

CREATE INDEX IF NOT EXISTS idx_scheduled_jobs_pending
  ON public.scheduled_jobs(status, scheduled_at)
  WHERE status = 'pending';

CREATE INDEX IF NOT EXISTS idx_scheduled_jobs_thread
  ON public.scheduled_jobs(thread_id, status);

-- 5. Function: Handle user message insert -> schedule AI timeout
CREATE OR REPLACE FUNCTION public.handle_user_message()
RETURNS TRIGGER AS $$
DECLARE
  v_existing_job_id uuid;
BEGIN
  IF NEW.sender_type != 'user' THEN
    RETURN NEW;
  END IF;

  UPDATE public.chat_threads
    SET last_user_message_at = NEW.created_at,
        awaiting_admin_response = true
    WHERE id = NEW.thread_id;

  SELECT id INTO v_existing_job_id
  FROM public.scheduled_jobs
  WHERE thread_id = NEW.thread_id
    AND job_type = 'ai_timeout'
    AND status = 'pending'
  LIMIT 1;

  IF v_existing_job_id IS NOT NULL THEN
    RETURN NEW;
  END IF;

  INSERT INTO public.scheduled_jobs (job_type, thread_id, scheduled_at)
  VALUES (
    'ai_timeout',
    NEW.thread_id,
    NEW.created_at + INTERVAL '10 minutes'
  );

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS tr_handle_user_message ON public.chat_messages;
CREATE TRIGGER tr_handle_user_message
  AFTER INSERT ON public.chat_messages
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_user_message();

-- 6. Function: Handle admin/sales reply -> cancel AI and reset state
CREATE OR REPLACE FUNCTION public.handle_admin_reply()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.sender_type NOT IN ('sales', 'admin') THEN
    RETURN NEW;
  END IF;

  UPDATE public.chat_threads
    SET ai_mode_active = false,
        awaiting_admin_response = false,
        assigned_sales_id = COALESCE(assigned_sales_id, NEW.sender_id),
        last_sales_reply_at = NEW.created_at,
        last_admin_message_at = NEW.created_at
    WHERE id = NEW.thread_id;

  UPDATE public.scheduled_jobs
    SET status = 'cancelled'
  WHERE thread_id = NEW.thread_id
    AND job_type = 'ai_timeout'
    AND status = 'pending';

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS tr_handle_admin_reply ON public.chat_messages;
CREATE TRIGGER tr_handle_admin_reply
  AFTER INSERT ON public.chat_messages
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_admin_reply();

-- 7. Function: Process AI timeout job (called by Edge Function)
CREATE OR REPLACE FUNCTION public.process_ai_timeout(p_job_id uuid)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_job public.scheduled_jobs;
  v_thread public.chat_threads;
  v_last_sender text;
BEGIN
  SELECT * INTO v_job
  FROM public.scheduled_jobs
  WHERE id = p_job_id AND status = 'pending'
  FOR UPDATE;

  IF v_job IS NULL THEN
    RETURN jsonb_build_object('status', 'skipped', 'reason', 'job not found or not pending');
  END IF;

  IF v_job.attempts >= v_job.max_attempts THEN
    UPDATE public.scheduled_jobs
      SET status = 'failed', error_message = 'Max attempts reached'
    WHERE id = p_job_id;
    RETURN jsonb_build_object('status', 'failed', 'reason', 'max attempts reached');
  END IF;

  UPDATE public.scheduled_jobs
    SET attempts = attempts + 1, status = 'processing'
  WHERE id = p_job_id;

  SELECT * INTO v_thread
  FROM public.chat_threads
  WHERE id = v_job.thread_id;

  IF v_thread IS NULL THEN
    UPDATE public.scheduled_jobs SET status = 'failed', error_message = 'Thread not found' WHERE id = p_job_id;
    RETURN jsonb_build_object('status', 'failed', 'reason', 'thread not found');
  END IF;

  SELECT cm.sender_type INTO v_last_sender
  FROM public.chat_messages cm
  WHERE cm.thread_id = v_job.thread_id
  ORDER BY cm.created_at DESC
  LIMIT 1;

  IF v_last_sender IS NOT NULL AND v_last_sender != 'user' THEN
    UPDATE public.scheduled_jobs SET status = 'completed', processed_at = now() WHERE id = p_job_id;
    UPDATE public.chat_threads SET awaiting_admin_response = false WHERE id = v_job.thread_id;
    RETURN jsonb_build_object('status', 'skipped', 'reason', 'admin already replied');
  END IF;

  UPDATE public.scheduled_jobs SET status = 'completed', processed_at = now() WHERE id = p_job_id;
  UPDATE public.chat_threads SET ai_mode_active = true WHERE id = v_job.thread_id;

  RETURN jsonb_build_object('status', 'ready', 'thread_id', v_job.thread_id::text);
END;
$$;

-- 8. Function: Handle AI message insert -> update thread timestamps
CREATE OR REPLACE FUNCTION public.handle_ai_message()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.sender_type = 'ai' THEN
    UPDATE public.chat_threads
      SET last_ai_message_at = NEW.created_at
    WHERE id = NEW.thread_id;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS tr_handle_ai_message ON public.chat_messages;
CREATE TRIGGER tr_handle_ai_message
  AFTER INSERT ON public.chat_messages
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_ai_message();

-- 9. RLS for scheduled_jobs
ALTER TABLE public.scheduled_jobs ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "scheduled_jobs service only" ON public.scheduled_jobs;
CREATE POLICY "scheduled_jobs service only" ON public.scheduled_jobs
  FOR ALL USING (false);

-- 10. Grant execute on process_ai_timeout to service role
GRANT EXECUTE ON FUNCTION public.process_ai_timeout(uuid) TO service_role;
GRANT EXECUTE ON FUNCTION public.handle_user_message() TO service_role;
GRANT EXECUTE ON FUNCTION public.handle_admin_reply() TO service_role;
GRANT EXECUTE ON FUNCTION public.handle_ai_message() TO service_role;
