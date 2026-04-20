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
| `SERVICE_ROLE_KEY` | `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imhxc3ppaHZqcXNjandkenJ3YnlhIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc3NTMyMTIwOSwiZXhwIjoyMDkwODk3MjA5fQ.xxx` (get from Settings → API) |

**Note**: The function uses the Supabase client with the service_role_key from the `SUPABASE_SERVICE_ROLE_KEY` environment variable, but the actual URL comes from the project settings automatically.

### Where to Get Service Role Key:
1. Supabase Dashboard → Settings → API
2. Copy "service_role secret"
3. Paste into the secret field

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
1. **No secrets set** → Add SERVICE_ROLE_KEY secret
2. **Session expired** → Sign out and sign back in
3. **CORS issue** → Check browser console for CORS errors

Check the logs first before reporting issues!
