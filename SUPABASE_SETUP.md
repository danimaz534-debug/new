# Supabase Edge Functions Setup

## Problem
The password reset and user creation features require Supabase Edge Functions that need to be deployed.

## Solution

### Option 1: Deploy the Edge Functions (Recommended)

1. **Install Supabase CLI** (if not already installed):
   ```powershell
   npm install -g supabase
   ```

2. **Login to Supabase**:
   ```powershell
   supabase login
   ```

3. **Link your project** (if not already linked):
   ```powershell
   supabase link --project-ref YOUR_PROJECT_REF
   ```
   You can find your project ref in your Supabase dashboard URL:
   `https://app.supabase.com/project/YOUR_PROJECT_REF`

4. **Deploy the functions**:
   ```powershell
   .\deploy-all-functions.ps1
   ```
   Or manually:
   ```powershell
   supabase functions deploy reset-user-password
   supabase functions deploy create-user
   ```

### Option 2: Quick Test Without Edge Functions

If you just want to test the UI without the Edge Functions, you can modify the code to show a message:

The functions I created are located at:
- `supabase/functions/reset-user-password/index.ts`
- `supabase/functions/create-user/index.ts`

## Verifying Deployment

After deployment, you can test the functions:

```powershell
# Test reset-user-password
supabase functions invoke reset-user-password --body '{"user_id":"test","new_password":"test123"}'

# Test create-user
supabase functions invoke create-user --body '{"email":"test@example.com","password":"test123","full_name":"Test User","role":"sales"}'
```

## Environment Variables Required

Make sure your Supabase project has these environment variables set:
- `SUPABASE_URL` (automatic)
- `SUPABASE_SERVICE_ROLE_KEY` (you need to add this in Project Settings > Edge Functions)

To add the service role key:
1. Go to your Supabase Dashboard
2. Navigate to Project Settings > Edge Functions
3. Add environment variable:
   - Name: `SUPABASE_SERVICE_ROLE_KEY`
   - Value: (get from Project Settings > API > service_role key)

## Troubleshooting

**Error: "Failed to send a request to the Edge Function"**
- The function is not deployed. Run the deployment steps above.

**Error: "Missing SUPABASE_SERVICE_ROLE_KEY"**
- Add the service role key to Edge Function environment variables.

**Error: "Insufficient permissions"**
- Make sure you're logged in as an admin user.
