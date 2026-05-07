-- Add avatar_url column to profiles table
alter table public.profiles add column if not exists avatar_url text default null;

-- Update comment
comment on column public.profiles.avatar_url is 'URL for user profile image/avatar';
