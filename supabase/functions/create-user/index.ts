import { createClient } from 'jsr:@supabase/supabase-js@2'
import { corsHeaders } from '../_shared/cors.ts'

Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    // 1. Initialize Supabase Admin Client
    const supabaseUrl = Deno.env.get('SUPABASE_URL') ?? ''
    const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? Deno.env.get('SERVICE_ROLE_KEY') ?? ''
    
    if (!supabaseUrl || !supabaseServiceKey) {
      console.error('Missing environment variables: SUPABASE_URL or SUPABASE_SERVICE_ROLE_KEY')
      return new Response(
        JSON.stringify({ error: 'Server configuration error' }),
        { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    const supabaseAdmin = createClient(supabaseUrl, supabaseServiceKey)

    // 2. Parse request body
    const body = await req.json()
    const { email, password, full_name, role } = body
    let { user_id } = body

    // 3. Authenticate the caller
    // First try Authorization header, then fallback to user_id in body
    const authHeader = req.headers.get('Authorization')
    if (authHeader) {
      const token = authHeader.replace('Bearer ', '')
      const { data: { user: caller }, error: authError } = await supabaseAdmin.auth.getUser(token)
      if (!authError && caller) {
        user_id = caller.id
      }
    }

    if (!user_id) {
      return new Response(
        JSON.stringify({ error: 'Unauthorized: No user session found' }),
        { status: 401, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // 4. Verify admin status
    const { data: profile, error: profileError } = await supabaseAdmin
      .from('profiles')
      .select('role, is_blocked')
      .eq('id', user_id)
      .single()

    if (profileError || !profile) {
      console.error('Verification error:', profileError)
      return new Response(
        JSON.stringify({ error: 'Failed to verify permissions' }),
        { status: 403, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    if (profile.role !== 'admin') {
      return new Response(
        JSON.stringify({ error: 'Forbidden: Admin role required' }),
        { status: 403, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    if (profile.is_blocked) {
      return new Response(
        JSON.stringify({ error: 'Forbidden: Your account is blocked' }),
        { status: 403, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // 5. Validate new user data
    if (!email || !password) {
      return new Response(
        JSON.stringify({ error: 'Email and password are required' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // 6. Create the user in Auth
    const { data: authData, error: authError } = await supabaseAdmin.auth.admin.createUser({
      email: email.trim(),
      password: password,
      user_metadata: { full_name: full_name?.trim() ?? '' },
      email_confirm: true
    })

    if (authError) {
      console.error('Auth user creation error:', authError)
      // Provide user-friendly error messages
      let userError = authError.message;
      const msg = authError.message?.toLowerCase() || '';
      if (msg.includes('already registered') || msg.includes('duplicate') || msg.includes('already exists') || msg.includes('email address') || msg.includes('user already')) {
        userError = 'Email already exists. Please use a different email.';
      } else if (msg.includes('weak password') || msg.includes('password') && msg.includes('weak')) {
        userError = 'Password is too weak. Please use a stronger password.';
      } else if (msg.includes('invalid email') || msg.includes('email format')) {
        userError = 'Invalid email format. Please enter a valid email address.';
      } else {
        // Generic fallback - don't expose internal error details
        userError = 'Failed to create user. Please try again.';
      }
      return new Response(
        JSON.stringify({ error: userError }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    const newUser = authData.user
    if (!newUser) {
      return new Response(
        JSON.stringify({ error: 'Failed to create user account' }),
        { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // 7. Create the profile for the new user
    const { error: profileInsertError } = await supabaseAdmin
      .from('profiles')
      .insert({
        id: newUser.id,
        email: email.trim(),
        full_name: full_name?.trim() ?? '',
        role: role || 'retail',
        preferred_language: 'en',
        is_blocked: false
      })

    if (profileInsertError) {
      console.error('Profile creation error:', profileInsertError)
      
      // Rollback: delete the auth user
      await supabaseAdmin.auth.admin.deleteUser(newUser.id)
      
      return new Response(
        JSON.stringify({ error: 'Profile creation failed: ' + profileInsertError.message }),
        { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    return new Response(
      JSON.stringify({
        message: 'User created successfully',
        user: {
          id: newUser.id,
          email: newUser.email,
          role: role || 'retail'
        }
      }),
      { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )

  } catch (error) {
    console.error('Unexpected error:', error)
    return new Response(
      JSON.stringify({ error: error.message || 'Internal server error' }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  }
})
