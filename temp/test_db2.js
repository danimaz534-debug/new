import { createClient } from '@supabase/supabase-js';

const supabaseUrl = 'https://hqszihvjqscrwdzrwbyg.supabase.co';
const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imhxc3ppaHZqcXNjcndkenJ3YnlnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzU0NzA4NzksImV4cCI6MjA5MTA0Njg3OX0.Oe6Jm4dduicJRhF_cGol7lLjWD3W5nNUiJqSvbhnaII';
const supabase = createClient(supabaseUrl, supabaseKey);

async function testProfile() {
  const { data, error } = await supabase.from('profiles').select('*').limit(1);
  if (error) {
    console.error('Error fetching profiles:', error.message);
  } else {
    console.log('Profiles table accessible. Rows:', data.length);
  }
}
testProfile();
