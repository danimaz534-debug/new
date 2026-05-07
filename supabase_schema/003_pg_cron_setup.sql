-- pg_cron setup for AI timeout processor
-- Run in Supabase SQL Editor AFTER deploying the ai-timeout-processor edge function

-- Enable pg_cron extension (Supabase Pro required, or use external cron)
CREATE EXTENSION IF NOT EXISTS pg_cron;

-- Schedule the AI timeout processor to run every minute
SELECT cron.schedule(
  'ai-timeout-processor',
  '* * * * *',
  $$
  SELECT net.http_post(
    url := current_setting('app.settings.supabase_url') || '/functions/v1/ai-timeout-processor',
    headers := jsonb_build_object(
      'Content-Type', 'application/json',
      'Authorization', 'Bearer ' || current_setting('app.settings.supabase_service_role_key')
    ),
    body := '{}'::text
  )
  $$
);

-- Alternative: If pg_cron is not available, use an external cron service
-- (e.g., GitHub Actions, cron-job.org, or Supabase pg_net) to POST to:
--   https://<your-project-ref>.supabase.co/functions/v1/ai-timeout-processor
-- every minute with an empty JSON body {}

-- Verify scheduled jobs
SELECT * FROM cron.job;

-- View recent job run logs
SELECT * FROM cron.job_run_details ORDER BY start_time DESC LIMIT 10;
