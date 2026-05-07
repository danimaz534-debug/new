# Avatar/Image Setup Guide

## Overview
Your Settings page now supports user avatar upload! Here's how to set it up:

## Step 1: Run Database Migration

1. Go to: https://app.supabase.com/project/hqszihvjqscrwdzrwbyg/sql

2. Copy and paste the contents of `add-avatar-column.sql`:

```sql
-- Add avatar_url column to profiles table
alter table public.profiles add column if not exists avatar_url text default null;

-- Update comment
comment on column public.profiles.avatar_url is 'URL for user profile image/avatar';
```

3. Click "Run" to execute the SQL.

## Step 2: Create Storage Bucket

1. Go to: https://app.supabase.com/project/hqszihvjqscrwdzrwbyg/storage/buckets

2. Click "Create bucket"

3. Enter:
   - **Name**: `avatars`
   - **Public bucket**: Checked (enabled)

4. Click "Create bucket"

## Step 3: Set Storage Policies

Option A: Quick Setup (Recommended)
1. Go to: https://app.supabase.com/project/hqszihvjqscrwdzrwbyg/sql
2. Run this SQL:

```sql
-- Create storage bucket for avatars
insert into storage.buckets (id, name, public)
values ('avatars', 'avatars', true);

-- Set up storage policies for avatars bucket
create policy "Avatar images are publicly accessible"
on storage.objects for select
using (bucket_id = 'avatars');

create policy "Users can upload their own avatar"
on storage.objects for insert
with check (
  bucket_id = 'avatars'
  and (storage.foldername(name))[1] = auth.uid()::text
);

create policy "Users can update their own avatar"
on storage.objects for update
using (
  bucket_id = 'avatars'
  and (storage.foldername(name))[1] = auth.uid()::text
);

create policy "Users can delete their own avatar"
on storage.objects for delete
using (
  bucket_id = 'avatars'
  and (storage.foldername(name))[1] = auth.uid()::text
);
```

Option B: Manual Setup
1. Go to: https://app.supabase.com/project/hqszihvjqscrwdzrwbyg/storage/policies
2. For bucket `avatars`, add policies:
   - **SELECT**: `bucket_id = 'avatars'` (checked)
   - **INSERT**: `bucket_id = 'avatars' AND (storage.foldername(name))[1] = auth.uid()::text`
   - **UPDATE**: `bucket_id = 'avatars' AND (storage.foldername(name))[1] = auth.uid()::text`
   - **DELETE**: `bucket_id = 'avatars' AND (storage.foldername(name))[1] = auth.uid()::text`

## Step 4: Test

1. Restart your dev server:
```powershell
cd "C:\Users\mhmd\Desktop\final project dani\web_app_react"
npm run dev
```

2. Go to `localhost:5173/dashboard/settings`

3. Upload an image:
   - Click "Upload Image"
   - Select an image file (max 2MB)
   - Click "Save" to apply

4. Check the Navbar (top-right):
   - Your avatar should now show instead of the initials!

## Features Added

**Settings Page:**
- Avatar upload with preview
- Max file size: 2MB
- Supported formats: JPG, PNG, GIF, WebP
- Images stored in Supabase Storage `avatars` bucket

**Navbar:**
- Shows user avatar (if uploaded)
- Falls back to initials (first letter of name/email)
- Circular display (36x36px)

## Troubleshooting

**"Bucket not found" error:**
- Make sure you created the `avatars` bucket in Step 2

**"Permission denied" error:**
- Make sure you set the storage policies in Step 3

**Image not showing in Navbar:**
- Make sure you clicked "Save" after uploading
- Check the `avatar_url` in Supabase Table Editor (`profiles` table)
