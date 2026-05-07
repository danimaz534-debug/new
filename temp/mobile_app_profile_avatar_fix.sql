alter table public.profiles
  add column if not exists avatar_url text;

create or replace function public.ensure_profile(
  p_full_name text default null,
  p_role text default 'retail',
  p_language text default 'en'
)
returns public.profiles
language plpgsql
security definer
set search_path = public
as $$
declare
  v_profile public.profiles;
begin
  insert into public.profiles (id, email, full_name, role, preferred_language, last_seen_at)
  values (
    auth.uid(),
    coalesce(auth.jwt() ->> 'email', ''),
    coalesce(
      nullif(trim(p_full_name), ''),
      auth.jwt() -> 'user_metadata' ->> 'full_name',
      auth.jwt() -> 'user_metadata' ->> 'name'
    ),
    coalesce(p_role, 'retail'),
    coalesce(p_language, 'en'),
    now()
  )
  on conflict (id) do update
    set email = excluded.email,
        full_name = case
          when public.profiles.full_name is null or trim(public.profiles.full_name) = ''
            then excluded.full_name
          else public.profiles.full_name
        end,
        preferred_language = coalesce(excluded.preferred_language, public.profiles.preferred_language),
        last_seen_at = now()
  returning * into v_profile;

  return v_profile;
end;
$$;

insert into storage.buckets (id, name, public)
values ('avatars', 'avatars', true)
on conflict (id) do update
  set public = excluded.public;

drop policy if exists "Avatar images are publicly accessible" on storage.objects;
create policy "Avatar images are publicly accessible"
on storage.objects
for select
using (bucket_id = 'avatars');

drop policy if exists "Users can upload their own avatar" on storage.objects;
create policy "Users can upload their own avatar"
on storage.objects
for insert
with check (
  bucket_id = 'avatars'
  and (storage.foldername(name))[1] = auth.uid()::text
);

drop policy if exists "Users can update their own avatar" on storage.objects;
create policy "Users can update their own avatar"
on storage.objects
for update
using (
  bucket_id = 'avatars'
  and (storage.foldername(name))[1] = auth.uid()::text
)
with check (
  bucket_id = 'avatars'
  and (storage.foldername(name))[1] = auth.uid()::text
);

drop policy if exists "Users can delete their own avatar" on storage.objects;
create policy "Users can delete their own avatar"
on storage.objects
for delete
using (
  bucket_id = 'avatars'
  and (storage.foldername(name))[1] = auth.uid()::text
);
