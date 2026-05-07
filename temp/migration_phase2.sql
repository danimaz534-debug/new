-- 1. Add avatar_url to profiles if it doesn't exist
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS avatar_url text;

-- 2. Create chat_summaries table
CREATE TABLE IF NOT EXISTS public.chat_summaries (
  id uuid primary key default gen_random_uuid(),
  thread_id uuid not null references public.chat_threads(id) on delete cascade,
  user_id uuid not null references public.profiles(id) on delete cascade,
  issue_description text not null,
  resolution_status text not null default 'Pending',
  resolved_by uuid references public.profiles(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

ALTER TABLE public.chat_summaries ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "chat summaries access" ON public.chat_summaries;
CREATE POLICY "chat summaries access" ON public.chat_summaries FOR SELECT USING (public.current_role() IN ('admin', 'sales') OR user_id = auth.uid());

DROP POLICY IF EXISTS "chat summaries update" ON public.chat_summaries;
CREATE POLICY "chat summaries update" ON public.chat_summaries FOR UPDATE USING (public.current_role() IN ('admin', 'sales') OR user_id = auth.uid()) WITH CHECK (public.current_role() IN ('admin', 'sales') OR user_id = auth.uid());

-- 3. Create 'avatars' storage bucket
INSERT INTO storage.buckets (id, name, public) VALUES ('avatars', 'avatars', true)
ON CONFLICT (id) DO NOTHING;

-- 4. Set up storage policies for 'avatars'
DROP POLICY IF EXISTS "Avatar images are publicly accessible." ON storage.objects;
CREATE POLICY "Avatar images are publicly accessible." ON storage.objects FOR SELECT USING (bucket_id = 'avatars');

DROP POLICY IF EXISTS "Anyone can upload an avatar." ON storage.objects;
CREATE POLICY "Anyone can upload an avatar." ON storage.objects FOR INSERT WITH CHECK (bucket_id = 'avatars');

DROP POLICY IF EXISTS "Anyone can update their avatar." ON storage.objects;
CREATE POLICY "Anyone can update their avatar." ON storage.objects FOR UPDATE USING (bucket_id = 'avatars');
