# Edge Function Deployment Complete!

## ✅ Status: DEPLOYED

The `create-user` edge function is now deployed to your Supabase project.

## 🔑 CRITICAL: Set Secrets in Dashboard

You MUST add these secrets in the Supabase Dashboard for the function to work:

### How to Add Secrets:

1. Go to: https://supabase.com/dashboard/project/hqszihvjqscrwdzrwbyg/functions
2. Click on **"create-user"** function
3. Click **"Secrets"** tab
4. Add these secrets:

| Secret Name | Value |
|------------|-------|
| `SUPABASE_SERVICE_ROLE_KEY` | `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imhxc3ppaHZqcXNjandkenJ3YnlhIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc3NTMyMTIwOSwiZXhwIjoyMDkwODk3MjA5fQ.xxx` (get from Settings → API) |
| `SUPABASE_ANON_KEY` | `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imhxc3ppaHZqcXNjcndkenJ3YnlnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzU0NzA4NzksImV4cCI6MjA5MTA0Njg3OX0.Oe6Jm4dduicJRhF_cGol7lLjWD3W5nNUiJqSvbhnaII` (get from Settings → API) |

**Note**: The function uses two Supabase clients:
- `supabaseAnon` with the anon key for token verification
- `supabaseAdmin` with the service_role key for admin operations

### Where to Get These Keys:
1. Supabase Dashboard → Settings → API
2. Copy "anon public" key for `SUPABASE_ANON_KEY`
3. Copy "service_role secret" for `SUPABASE_SERVICE_ROLE_KEY`
4. Paste each into their respective secret fields

## 🧪 Testing the Function

After adding secrets, test user creation:

1. Sign in to web app as admin
2. Go to Users page
3. Click "Create New User"
4. Fill form and submit
5. Check browser console for success!

## 📊 View Function Logs

If it still fails:
1. Dashboard → Edge Functions → create-user
2. Click "Logs" tab
3. Look for error messages
4. Share logs if you need help

## 🔧 Alternative: Using config.toml

If you prefer, create `supabase/config.toml`:

```toml
[functions.create-user]
verify_jwt = true
```

And the project URL is auto-detected.

## ❓ Still Getting 401?

The 401 error could mean:
1. **Missing secrets** → Add both SUPABASE_SERVICE_ROLE_KEY and SUPABASE_ANON_KEY secrets
2. **Session expired** → Sign out and sign back in
3. **CORS issue** → Check browser console for CORS errors
4. **Function not deployed** → Make sure the Edge Function is deployed with the latest code

Check the logs first before reporting issues!
