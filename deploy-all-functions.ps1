# Deploy all Supabase Edge Functions
# Make sure you're logged in: supabase login
# Make sure you're linked to your project: supabase link --project-ref YOUR_PROJECT_REF

Write-Host "Deploying Edge Functions..." -ForegroundColor Green

# Deploy reset-user-password function
Write-Host "Deploying reset-user-password..." -ForegroundColor Yellow
supabase functions deploy reset-user-password

# Deploy create-user function  
Write-Host "Deploying create-user..." -ForegroundColor Yellow
supabase functions deploy create-user

Write-Host "All functions deployed!" -ForegroundColor Green
Write-Host "If you get errors, make sure:" -ForegroundColor Cyan
Write-Host "1. You're logged in: supabase login" -ForegroundColor Cyan
Write-Host "2. You're linked to your project: supabase link --project-ref YOUR_REF" -ForegroundColor Cyan
Write-Host "3. Your project ref is in supabase/config.toml" -ForegroundColor Cyan
