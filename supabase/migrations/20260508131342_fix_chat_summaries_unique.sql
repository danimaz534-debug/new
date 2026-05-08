-- Fix chat_summaries: add unique constraint on thread_id so upsert works
ALTER TABLE public.chat_summaries
  ADD CONSTRAINT chat_summaries_thread_id_unique UNIQUE (thread_id);

-- Clean up any existing duplicates (keep the latest per thread)
DELETE FROM public.chat_summaries a
USING public.chat_summaries b
WHERE a.id < b.id
  AND a.thread_id = b.thread_id;
