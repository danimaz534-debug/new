# Quick Setup Guide

## Fix Password Reset "Edge Function" Error

The error happens because the Edge Functions aren't deployed to your Supabase project yet.

### Step 1: Install Supabase CLI
```powershell
npm install -g supabase
```

### Step 2: Login to Supabase
```powershell
supabase login
```

### Step 3: Link Your Project
1. Go to https://app.supabase.com/project/YOUR_PROJECT_REF/settings/general
2. Copy your "Reference ID" (e.g., `abcdefghijklmnop`)
3. Run:
```powershell
supabase link --project-ref YOUR_PROJECT_REF
```

### Step 4: Add Service Role Key
1. Go to https://app.supabase.com/project/YOUR_PROJECT_REF/settings/api
2. Copy the "service_role" key (under "Project API keys")
3. Add it to Edge Function environment:
```powershell
supabase secrets set SUPABASE_SERVICE_ROLE_KEY=your_service_role_key_here
```

### Step 5: Deploy the Functions
```powershell
supabase functions deploy reset-user-password
supabase functions deploy create-user
```

### Step 6: Test
Restart your React app:
```powershell
cd "C:\Users\mhmd\Desktop\final project dani\web_app_react"
npm run dev
```

## Alternative: Quick Fix Without Edge Functions

If you can't deploy Edge Functions right now, modify `commerce.js` to show a proper error:

The password reset needs admin privileges. Without the Edge Function, you can't reset passwords from the dashboard.

## Verify Functions Are Deployed

Go to: https://app.supabase.com/project/YOUR_PROJECT_REF/functions
You should see `reset-user-password` and `create-user` listed there.
