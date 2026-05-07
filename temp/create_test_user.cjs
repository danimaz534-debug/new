const { createClient } = require('@supabase/supabase-js');

const supabaseUrl = 'https://hqszihvjqscrwdzrwbyg.supabase.co';
const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imhxc3ppaHZqcXNjcndkenJ3YnlnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzU0NzA4NzksImV4cCI6MjA5MTA0Njg3OX0.Oe6Jm4dduicJRhF_cGol7lLjWD3W5nNUiJqSvbhnaII';

const supabase = createClient(supabaseUrl, supabaseKey);

async function createTestUser() {
  // Sign up a new admin user
  const { data, error } = await supabase.auth.signUp({
    email: 'admin@test.com',
    password: 'Test123!',
    options: {
      data: {
        full_name: 'Test Admin',
        role: 'admin'
      }
    }
  });

  if (error) {
    console.error('Error creating user:', error.message);
    return;
  }

  console.log('User created successfully:', data.user?.email);
  
  // Create profile using the ensure_profile function
  if (data.user) {
    const { error: profileError } = await supabase.rpc('ensure_profile', {
      p_full_name: 'Test Admin',
      p_role: 'admin',
      p_language: 'en'
    });

    if (profileError) {
      console.error('Error creating profile:', profileError.message);
    } else {
      console.log('Profile created successfully');
    }
  }
}

createTestUser();